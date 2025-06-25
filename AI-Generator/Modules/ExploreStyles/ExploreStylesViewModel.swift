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
}

protocol ExploreStylesViewModelToView {
    var input: ExploreStylesViewModelInputs { get }
    var output: ExploreStylesViewModelOutputs { get }
}

protocol ExploreStylesViewModelToCoordinator {
    
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
    
    // Coordinator Inputs
    
    init(apiService: PixVerseAPIServiceProtocol, storageService: UserDefaultsServiceProtocol, cacheService: CacheServiceProtocol) {
        self.apiService = apiService
        self.storageService = storageService
        self.cacheService = cacheService
        
        setupBindings()
    }
    
    func setupBindings() {
        loadTrigger.subscribe(onNext: {
            self.loadStyles()
        })
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

        
//        let generatedVideos = storageService.getAllGeneratedVideos()
//
//        let videoCellModels = generatedVideos
//            .compactMap { video -> GeneratedVideoCellModel? in
//                guard let stringUrl = video.video_url,
//                      let url = URL(string: stringUrl) else { return nil }
//                return GeneratedVideoCellModel(previewImage: UIImage(), videoURL: url)
//            }
//
//        _sectionedVideos.accept([SectionOfVideos(items: videoCellModels)])
    }
}
