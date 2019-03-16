
import UIKit
import InfiniteLayout
import Reusable
import RxSwift
import RxCocoa



public class RxInfinitePicker: UIView {
    
    private var itemSize: CGSize
    
    private lazy var collectionView: RxInfiniteCollectionView = {
        let collectionView = RxInfiniteCollectionView(frame: .zero, collectionViewLayout: {
            let layout = UICollectionViewFlowLayout()
            layout.minimumLineSpacing = 0
            layout.minimumInteritemSpacing = 0
            layout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
            layout.itemSize = itemSize
            layout.scrollDirection = .vertical
            return layout
        }())
        collectionView.backgroundColor = .clear
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.isItemPagingEnabled = true
        collectionView.register(cellType: LabelPickerCell.self)
        collectionView.rx.itemSelected.bind { [unowned self] in
            self.itemSelected.onNext($0.row)
            collectionView.scrollToItem(at: $0, at: .centeredVertically, animated: true)
        }.disposed(by: disposeBag)
        collectionView.rx.itemCentered.filter { $0 != nil }.map { $0! }.skip(1).bind { [unowned self] in
            self.itemSelected.onNext($0.row)
        }.disposed(by: disposeBag)
        return collectionView
    }()
    
    private lazy var dataSource = InfiniteCollectionViewSingleSectionDataSource<Int>(configureCell: { (_, collectionView, indexPath, data) in
        let cell = collectionView.dequeueReusableCell(for: indexPath) as LabelPickerCell
        cell.title = String(data)
        return cell
    })
    
    public let items = PublishSubject<[Int]>()
    public let itemSelected = BehaviorSubject<Int>(value: 0)
    
    private let disposeBag = DisposeBag()
    
    public init(frame: CGRect = .zero, itemSize: CGSize) {
        self.itemSize = itemSize
        super.init(frame: frame)
        
        addSubview(collectionView)
        createConstraints()
        
        items.map { SingleSection.create($0) }
            .asDriver(onErrorJustReturn: [])
            .drive(collectionView.rx.items(dataSource: dataSource))
            .disposed(by: disposeBag)
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func createConstraints() {
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        collectionView.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        collectionView.topAnchor.constraint(equalTo: topAnchor).isActive = true
        collectionView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
    }
    
}
