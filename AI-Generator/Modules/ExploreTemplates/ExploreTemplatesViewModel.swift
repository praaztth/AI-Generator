//
//  ExploreTemplatesViewModel.swift
//  AI-Generator
//
//  Created by катенька on 18.06.2025.
//

import RxSwift
import RxCocoa

protocol ExploreTemplatesViewControllerInput {
    func displayTemplates()
}

class ExploreTemplatesViewModel: ExploreTemplatesViewControllerOutput {
    private let apiService: PixVerseAPIServiceProtocol
    private let disposeBag = DisposeBag()

    let openPaywallEvent = PublishRelay<Void>()
    let chooseTemplateEvent = PublishRelay<Int>()
    let cacheService: CacheServiceProtocol
    
    lazy var sectionsDriver: Driver<[SectionOfTemplates]> = {
        return apiService.fetchTemplates()
            .map { templateResponse in
                templateResponse.templates.forEach { template in
                    let cachedTemplate = CachableTemplate(data: template)
                    self.cacheService.setObject(cachedTemplate, forKey: String(template.template_id))
                }
                
                var sections: [SectionOfTemplates] = []
                let categories: [String] = templateResponse.templates.map { $0.category }.reduce(into: []) { result, element in
                    if !result.contains(element) {
                        result.append(element)
                    }
                }
                
                categories.forEach { category in
                    let items = templateResponse.templates.filter { $0.category == category }
                    let sectionItem = SectionOfTemplates(header: category, items: items)
                    sections.append(sectionItem)
                }
                
                return sections
            }
            .asDriver(onErrorJustReturn: [])
    }()
    
    init(apiService: PixVerseAPIServiceProtocol, templatesCache: CacheServiceProtocol) {
        self.apiService = apiService
        self.cacheService = templatesCache
    }
    
    func didTapTemplate(at index: Int) {
        chooseTemplateEvent.accept(index)
    }
    
    func didTapOpenPaywall() {
        openPaywallEvent.accept(())
    }
}
