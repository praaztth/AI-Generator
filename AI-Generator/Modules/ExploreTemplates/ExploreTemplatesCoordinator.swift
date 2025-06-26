//
//  ExploreTemplatesCoordinator.swift
//  AI-Generator
//
//  Created by катенька on 18.06.2025.
//

import UIKit
import RxSwift
import RxCocoa

final class ExploreTemplatesCoordinator: BaseCoordinator {
//    var childCoordinators: [CoordinatorProtocol] = []
//    var navigationController = UINavigationController()
    let apiService: PixVerseAPIServiceProtocol
    let storageService: UserDefaultsServiceProtocol
//    var didFinish = PublishSubject<Void>()
//    let disposeBag = DisposeBag()
    
    private let _openPaywallEvent = PublishRelay<Void>()
    var openPaywallEvent: Driver<Void> {
        _openPaywallEvent.asDriver(onErrorJustReturn: ())
    }
    
    
    init(apiService: PixVerseAPIServiceProtocol, storageService: UserDefaultsServiceProtocol, navigationController: UINavigationController) {
        self.apiService = apiService
        self.storageService = storageService
        super.init(navigationController: navigationController)
    }
    
    override func start() {
        let viewModel = ExploreTemplatesViewModel(apiService: apiService, templatesCache: CacheService.shared)
        let viewController = ExploreTemplatesViewController(viewModel: viewModel)
        navigationController.viewControllers = [viewController]
        
        viewModel.chooseTemplateEvent.subscribe(onNext: { templateId in
            self.goToTemplate(id: templateId)
        }).disposed(by: disposeBag)
        
        viewModel.openPaywallEvent
            .bind(to: _openPaywallEvent)
            .disposed(by: disposeBag)
    }
    
    override func finish() {}
    
    func goToTemplate(id: Int) {
        let coordinator = UseEffectsCoordinator(effectID: id, apiService: apiService, storageService: storageService, navigationController: navigationController)
        coordinator.start()
        childCoordinators.append(coordinator)
        
        coordinator.didFinish
            .subscribe(onNext: {
                self.childDidFinished(child: coordinator)
            })
            .disposed(by: disposeBag)
        
        coordinator.shouldOpenPaywall
            .bind(to: _openPaywallEvent)
            .disposed(by: disposeBag)
    }
    
    func goToResultView(videoURL: URL) {
        let coordinator = VideoResultCoordinator(videoURL: videoURL, navigationController: navigationController, storageService: storageService)
        coordinator.start()
        childCoordinators.append(coordinator)
        
        coordinator.didFinish.subscribe(onNext: {
            self.childDidFinished(child: coordinator)
        }).disposed(by: disposeBag)
    }
}
