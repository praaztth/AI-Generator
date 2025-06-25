//
//  UseStyleViewModel.swift
//  AI-Generator
//
//  Created by катенька on 25.06.2025.
//

import Foundation
import RxSwift
import RxCocoa

protocol UseStylesViewModelInputs {
    
}

protocol UseStylesViewModelOutputs {
    
}

protocol UseStylesViewModelToView {
    var input: UseStylesViewModelInputs { get }
    var output: UseStylesViewModelOutputs { get }
}

protocol UseStylesViewModelToCoordinator {
    
}

class UseStylesViewModel: ViewModelConfigurable, UseStylesViewModelInputs, UseStylesViewModelOutputs, UseStylesViewModelToView, UseStylesViewModelToCoordinator {
    private let apiService: PixVerseAPIServiceProtocol
    private let storageService: UserDefaultsServiceProtocol
    private let cacheService: CacheServiceProtocol
    private let disposeBag = DisposeBag()
    
    var input: UseStylesViewModelInputs { self }
    var output: UseStylesViewModelOutputs { self }
    
    // ViewController Inputs
    
    // ViewController Outputs
    
    // Coordinator Inputs
    
    init(apiService: PixVerseAPIServiceProtocol, storageService: UserDefaultsServiceProtocol, cacheService: CacheServiceProtocol) {
        self.apiService = apiService
        self.storageService = storageService
        self.cacheService = cacheService
        
        setupBindings()
    }
    
    func setupBindings() {
        
    }
}
