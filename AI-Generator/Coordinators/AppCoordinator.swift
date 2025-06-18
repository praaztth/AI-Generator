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
    
    func start()
}

final class AppCoordinator: CoordinatorProtocol {
    var childCoordinators: [CoordinatorProtocol] = []
    var navigationController: UINavigationController
    var userDefaultsService: UserDefaultsServiceProtocol
    let disposeBag = DisposeBag()
    
//    var hasCompletedOnboarding: Bool {
//        get {
//            UserDefaults.standard.bool(forKey: "hasCompletedOnboarding")
//        }
//        set {
//            UserDefaults.standard.set(newValue, forKey: "hasCompletedOnboarding")
//        }
//    }
    
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
            self.goToPaywall()
            self.childDidFinished(child: coordinator)
            
        }).disposed(by: disposeBag)
    }
    
    func goToPaywall() {
        let coordinator = PaywallCoordinator(navigationController: navigationController)
        coordinator.start()
        childCoordinators.append(coordinator)
    }
    
    func childDidFinished(child: CoordinatorProtocol) {
        if let index = childCoordinators.firstIndex(where: { $0 === child }) {
            childCoordinators.remove(at: index)
        }
    }
}
