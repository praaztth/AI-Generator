//
//  ExploreTemplatesCoordinator.swift
//  AI-Generator
//
//  Created by катенька on 18.06.2025.
//

import UIKit
import RxSwift

class ExploreTemplatesCoordinator: CoordinatorProtocol {
    var childCoordinators: [CoordinatorProtocol] = []
    var navigationController: UINavigationController
    var didFinish = PublishSubject<Void>()
    let disposeBag = DisposeBag()
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    func start() {
        let apiService = PixVerseAPIService()
        let viewModel = ExploreTemplatesViewModel(apiService: apiService)
        let viewController = ExploreTemplatesViewController(viewModel: viewModel)
        navigationController.viewControllers = [viewController]
        viewModel.openPaywallEvent.subscribe(onNext: {
            self.showPaywall()
        }).disposed(by: disposeBag)
    }
    
    func showPaywall() {
        let coordinator = PaywallCoordinator(navigationController: navigationController)
        coordinator.start()
        childCoordinators.append(coordinator)
        
        coordinator.didFinish.subscribe(onNext: {
            self.childDidFinished(child: coordinator)
        }).disposed(by: disposeBag)
    }
}
