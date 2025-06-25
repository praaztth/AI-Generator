//
//  ExploreStylesViewModel.swift
//  AI-Generator
//
//  Created by катенька on 25.06.2025.
//

import Foundation
import RxSwift
import RxCocoa

protocol ExploreStylesViewModelInputs {
    var sectionedStylesDriver: Driver<[SectionOfStyles]> { get }
}

protocol ExploreStylesViewModelOutputs {
    var loadTrigger: PublishRelay<Void> { get }
    var didSelectStyle: PublishRelay<Style> { get }
    var didTapOpenPaywall: PublishRelay<Void> { get }
}

protocol ExploreStylesViewModelToView {
    var input: ExploreStylesViewModelInputs { get }
    var output: ExploreStylesViewModelOutputs { get }
}

protocol ExploreStylesViewModelToCoordinator {
    var shouldOpenStyle: Driver<Style> { get }
    var shouldOpenPaywall: Driver<Void> { get }
}

class ExploreStylesViewModel: ViewModelConfigurable, ExploreStylesViewModelInputs, ExploreStylesViewModelOutputs, ExploreStylesViewModelToView, ExploreStylesViewModelToCoordinator {
    private let apiService: PixVerseAPIServiceProtocol
    private let storageService: UserDefaultsServiceProtocol
    private let cacheService: CacheServiceProtocol
    private let disposeBag = DisposeBag()
    
    var input: ExploreStylesViewModelInputs { self }
    var output: ExploreStylesViewModelOutputs { self }
    
    // ViewController Inputs
    private let _sectionedStyles = PublishRelay<[SectionOfStyles]>()
    var sectionedStylesDriver: Driver<[SectionOfStyles]> {
        _sectionedStyles
            .asDriver(onErrorJustReturn: [])
    }
    
    // ViewController Outputs
    var loadTrigger = PublishRelay<Void>()
    var didSelectStyle = PublishRelay<Style>()
    var didTapOpenPaywall = PublishRelay<Void>()
    
    // Coordinator Inputs
    private let _shouldOpenStyle = PublishRelay<Style>()
    var shouldOpenStyle: Driver<Style> {
        _shouldOpenStyle.asDriver(onErrorJustReturn: Style.empty())
    }
    
    private let _shouldOpenPaywall = PublishRelay<Void>()
    var shouldOpenPaywall: Driver<Void> {
        _shouldOpenPaywall.asDriver(onErrorJustReturn: ())
    }
    
    init(apiService: PixVerseAPIServiceProtocol, storageService: UserDefaultsServiceProtocol, cacheService: CacheServiceProtocol) {
        self.apiService = apiService
        self.storageService = storageService
        self.cacheService = cacheService
        
        setupBindings()
    }
    
    func setupBindings() {
        loadTrigger
            .subscribe(onNext: {
                self.loadStyles()
            })
            .disposed(by: disposeBag)
        
        didSelectStyle
            .subscribe(onNext: { selectedStyle in
                self._shouldOpenStyle.accept(selectedStyle)
            })
            .disposed(by: disposeBag)
        
        didTapOpenPaywall
            .bind(to: _shouldOpenPaywall)
            .disposed(by: disposeBag)
    }
    
    func loadStyles() {
        apiService.fetchTemplates()
            .map { templateResponse in
                templateResponse.styles.forEach { style in
                    let cachedStyle = CachableStyle(data: style)
                    self.cacheService.setObject(cachedStyle, forKey: String(style.template_id))
                }
                
                let sections = [SectionOfStyles(items: templateResponse.styles)]
                return sections
            }
            .subscribe { sections in
                self._sectionedStyles.accept(sections)
            } onFailure: { error in
                print("\(#file): \(error)")
            }
            .disposed(by: disposeBag)
    }
}
