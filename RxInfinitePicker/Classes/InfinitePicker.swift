
import UIKit
import InfiniteLayout
import RxSwift
import RxCocoa

fileprivate struct Const {
    static let pickerCellIdentider = "RxInfinitePicker.CellIdentider"
}

public protocol InfinitePickerDelegate: class {
    func didSelectItem(at index: Int)
}

public class InfinitePicker<Model>: UIView, UICollectionViewDataSource, UICollectionViewDelegate, InfiniteCollectionViewDelegate {

    private let itemSize: CGSize
    private let scrollDirection: UICollectionView.ScrollDirection
    private let cellType: InfinitePickerCell<Model>.Type
    
    private var currentIndex = 0
    
    private lazy var collectionView: InfiniteCollectionView = {
        let collectionView = InfiniteCollectionView(frame: .zero, collectionViewLayout: {
            let layout = UICollectionViewFlowLayout()
            layout.minimumLineSpacing = 0
            layout.minimumInteritemSpacing = 0
            layout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
            layout.itemSize = itemSize
            layout.scrollDirection = scrollDirection
            return layout
        }())
        collectionView.backgroundColor = .clear
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.isItemPagingEnabled = true
        collectionView.register(cellType, forCellWithReuseIdentifier: Const.pickerCellIdentider)
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.infiniteDelegate = self
        return collectionView
    }()
    
    public var items: [Model] = [] {
        didSet {
            collectionView.reloadData()
        }
    }
    
    public weak var delegate: InfinitePickerDelegate?
    
    public init(
        frame: CGRect = .zero,
        itemSize: CGSize,
        scrollDirection: UICollectionView.ScrollDirection,
        cellType: InfinitePickerCell<Model>.Type
    ) {
        self.itemSize = itemSize
        self.scrollDirection = scrollDirection
        self.cellType = cellType
        super.init(frame: frame)

        addSubview(collectionView)
        createConstraints()
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
    
    private var scrollPosition: UICollectionView.ScrollPosition {
        switch scrollDirection {
        case .vertical:
            return .centeredVertically
        case .horizontal:
            return .centeredHorizontally
        }
    }
    
    public func pick(at index: Int) {
        guard 0 ..< items.count ~= index else {
            return
        }
        let indexPath = IndexPath(row: currentIndex - currentIndex % items.count + index, section: 0)
        collectionView.selectItem(at: indexPath, animated: true, scrollPosition: scrollPosition)
    }
    
    // MARK: UICollectionViewDataSource
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return items.count
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let index = self.collectionView.indexPath(from: indexPath).row
        guard
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Const.pickerCellIdentider, for: indexPath) as? InfinitePickerCell<Model>,
            0 ..< items.count ~= index
            
        else {
            return UICollectionViewCell()
        }
        cell.model = items[index]
        return cell
    }
    
    // MARK: UICollectionViewDelegate
    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.scrollToItem(at: indexPath, at: scrollPosition, animated: true)
    }
    
    //  MARK: InfiniteCollectionViewDelegate
    public func infiniteCollectionView(_ infiniteCollectionView: InfiniteCollectionView, didChangeCenteredIndexPath centeredIndexPath: IndexPath?) {
        guard let indexPath = centeredIndexPath else {
            return
        }
        currentIndex = indexPath.row
        delegate?.didSelectItem(at: collectionView.indexPath(from: indexPath).row)
    }
    
}