//
//  AppCoordinator.swift
//  AI-Generator
//
//  Created by катенька on 17.06.2025.
//

import UIKit
import RxSwift

protocol CoordinatorProtocol: AnyObject {
    var childCoordinators: [CoordinatorProtocol] { get set }
    var navigationController: UINavigationController { get set }
    var didFinish: PublishSubject<Void> { get }
    func childDidFinished(child: CoordinatorProtocol)
    
    func start()
}

extension CoordinatorProtocol {
    func childDidFinished(child: CoordinatorProtocol) {
        if let index = childCoordinators.firstIndex(where: { $0 === child }) {
            childCoordinators.remove(at: index)
        }
    }
}

final class AppCoordinator: CoordinatorProtocol {
    var childCoordinators: [CoordinatorProtocol] = []
    var navigationController: UINavigationController
    var userDefaultsService: UserDefaultsServiceProtocol
    var didFinish = PublishSubject<Void>()
    let disposeBag = DisposeBag()
    
    init(navigationController: UINavigationController, userDefaultsService: UserDefaultsServiceProtocol) {
        self.navigationController = navigationController
        self.userDefaultsService = userDefaultsService
    }
    
    func start() {
        if !userDefaultsService.hasCompletedOnboarding {
            goToOnBoarding()
        }
    }
    
    func goToOnBoarding() {
        let coordinator = OnBoardingCoordinator(navigationController: navigationController)
        coordinator.start()
        childCoordinators.append(coordinator)
        
        coordinator.didFinish.subscribe(onNext: {
//            self.userDefaultsService.hasCompletedOnboarding = true
            self.goToExploreTemplates()
            self.childDidFinished(child: coordinator)
            
        }).disposed(by: disposeBag)
    }
    
    func goToExploreTemplates() {
        let coordinator = ExploreTemplatesCoordinator(navigationController: navigationController)
        coordinator.start()
        coordinator.showPaywall()
        childCoordinators.append(coordinator)
    }
}
