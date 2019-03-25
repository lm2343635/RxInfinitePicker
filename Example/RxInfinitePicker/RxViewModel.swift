//
//  RxViewModel.swift
//  RxInfinitePicker_Example
//
//  Created by Meng Li on 2019/03/15.
//  Copyright © 2019 CocoaPods. All rights reserved.
//

import RxSwift
import RxCocoa

class RxViewModel {
    
    let items = BehaviorRelay<[Int]>(value: Array(1 ... 9))
    let selectedIndex = PublishSubject<Int>()
    
    var number: Observable<String?> {
        return selectedIndex.map { String($0) }
    }
    
    func pick(at index: Int) {
        print("itemSelected \(index)")
    }
    
    func update() {
        selectedIndex.onNext(Int.random(in: 0 ..< 9))
    }
    
}
