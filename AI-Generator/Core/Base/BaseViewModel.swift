//
//  BaseViewModel.swift
//  AI-Generator
//
//  Created by катенька on 26.06.2025.
//

import RxSwift
import RxCocoa

protocol ViewModelToCoordinator {
    var shouldShowLoading: Driver<Bool> { get }
}

class BaseViewModel {
    internal let _shouldShowLoading = PublishRelay<Bool>()
    var shouldShowLoading: Driver<Bool> {
        _shouldShowLoading.asDriver(onErrorJustReturn: false)
    }
    
    init() {
        setupBindings()
    }
    
    func setupBindings() { fatalError("\(#function) has not been implemented") }
}
