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
    
    let sectionsDriver: Driver<[SectionOfTemplates]>
    let openPaywallEvent = PublishRelay<Void>()
    
    init(apiService: PixVerseAPIServiceProtocol) {
        self.apiService = apiService
        self.sectionsDriver = apiService.fetchTemplates()
            .map {
                var sections: [SectionOfTemplates] = []
                let templateItems = $0.templates.map { TemplateItem.template($0) }
                let styleItems = $0.styles.map { TemplateItem.style($0) }
                sections.append(SectionOfTemplates(header: "Templates", items: templateItems))
                sections.append(SectionOfTemplates(header: "Styles", items: styleItems))
                return sections
            }
            .asDriver(onErrorJustReturn: [])
    }
    
    func didTapOpenPaywall() {
        openPaywallEvent.accept(())
    }
}

class MockAPIService: PixVerseAPIServiceProtocol {
    func fetchTemplates() -> Single<TemplateResponse> {
        let jsonTemplatesData = """
            {"app_id":"com.test.test","templates":[{"prompt":"One click to send your kiss","name":"Kiss Kiss","category":"Trending","is_active":true,"preview_small":"https://api-use-core.store/static/video/small/d78624dd73014d71b10870054fcbce52.mp4","preview_large":"https://api-use-core.store/static/video/large/3e5346fbff66465ba86509f1393bbcfc.mp4","id":137,"template_id":315446315336768},{"prompt":"Show off your strong muscles and have everyone hooked.","name":"Muscle Surge","category":"Trending","is_active":true,"preview_small":"https://api-use-core.store/static/video/small/b17d85208f1548d8b0db0fd086b0b3ae.mp4","preview_large":"https://api-use-core.store/static/video/large/401f5debfa3d4cdd8c21a04edcaeea9b.mp4","id":140,"template_id":308621408717184}],"id":1}
        """.data(using: .utf8)!
        
        return Single<TemplateResponse>.create { single in
            do {
                let items = try JSONDecoder().decode(TemplateResponse.self, from: jsonTemplatesData)
                single(.success(items))
                
            } catch {
                single(.failure(error))
            }
            return Disposables.create()
        }
    }
}
