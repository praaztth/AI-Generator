//
//  ExploreTemplatesCoordinator.swift
//  AI-Generator
//
//  Created by катенька on 18.06.2025.
//

import UIKit
import RxSwift

final class ExploreTemplatesCoordinator: CoordinatorProtocol {
    var childCoordinators: [CoordinatorProtocol] = []
    var navigationController: UINavigationController
    let apiService: PixVerseAPIServiceProtocol
    let storageService: UserDefaultsServiceProtocol
    var didFinish = PublishSubject<Void>()
    let disposeBag = DisposeBag()
    
    init(apiService: PixVerseAPIServiceProtocol, storageService: UserDefaultsServiceProtocol, navigationController: UINavigationController) {
        self.apiService = apiService
        self.storageService = storageService
        self.navigationController = navigationController
    }
    
    func start() {
        let viewModel = ExploreTemplatesViewModel(apiService: apiService, templatesCache: CacheService.shared)
        let viewController = ExploreTemplatesViewController(viewModel: viewModel)
        navigationController.viewControllers = [viewController]
        
        viewModel.chooseTemplateEvent.subscribe(onNext: { templateId in
            self.goToTemplate(id: templateId)
        }).disposed(by: disposeBag)
        
        viewModel.openPaywallEvent.subscribe(onNext: {
            self.showPaywall()
        }).disposed(by: disposeBag)
    }
    
    func finish() {}
    
    func goToTemplate(id: Int) {
        let coordinator = UseEffectsCoordinator(effectID: id, apiService: apiService, storageService: storageService, navigationController: navigationController)
        coordinator.start()
        childCoordinators.append(coordinator)
        
        coordinator.didFinish
            .subscribe(onNext: {
                self.childDidFinished(child: coordinator)
            })
            .disposed(by: disposeBag)
    }
    
    func showPaywall() {
        let coordinator = PaywallCoordinator(navigationController: navigationController)
        coordinator.start()
        childCoordinators.append(coordinator)
        
        coordinator.didFinish.subscribe(onNext: {
            self.childDidFinished(child: coordinator)
        }).disposed(by: disposeBag)
    }
    
    func goToLoadingView() {
        let viewController = VideoGenerationProcessViewController()
        navigationController.pushViewController(viewController, animated: true)
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
