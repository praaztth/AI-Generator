//
//  BaseViewModel.swift
//  AI-Generator
//
//  Created by катенька on 26.06.2025.
//

import Foundation
import RxSwift
import RxCocoa

protocol ViewModelToCoordinator {
    var shouldShowLoading: Driver<Bool> { get }
    var shouldOpenLink: Driver<URL> { get }
}

class BaseViewModel {
    internal let _shouldShowLoading = PublishRelay<Bool>()
    var shouldShowLoading: Driver<Bool> {
        _shouldShowLoading.asDriver(onErrorJustReturn: false)
    }
    
    internal let _shouldOpenLink = PublishRelay<URL>()
    var shouldOpenLink: Driver<URL> {
        _shouldOpenLink.asDriver(onErrorJustReturn: URL(string: "https://example.com")!)
    }
    
    init() {
        setupBindings()
    }
    
    func setupBindings() { fatalError("\(#function) has not been implemented") }
}
