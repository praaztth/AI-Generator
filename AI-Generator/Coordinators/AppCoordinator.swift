//
//  AppCoordinator.swift
//  AI-Generator
//
//  Created by катенька on 17.06.2025.
//

import UIKit

protocol CoordinatorProtocol: AnyObject {
    var childCoordinators: [CoordinatorProtocol] { get set }
    var navigationController: UINavigationController { get set }
    
    func start()
}

final class AppCoordinator: CoordinatorProtocol {
    var childCoordinators: [CoordinatorProtocol] = []
    var navigationController: UINavigationController
    
    var hasCompletedOnboarding: Bool {
        get {
            UserDefaults.standard.bool(forKey: "hasCompletedOnboarding")
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "hasCompletedOnboarding")
        }
    }
    
    
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    func start() {
        if !hasCompletedOnboarding {
            goToOnBoarding()
        }
    }
    
    func goToOnBoarding() {
        let coordinator = OnBoardingCoordinator(navigationController: navigationController)
        coordinator.start()
        childCoordinators.append(coordinator)
//        let page = pages[currentIndex]
//        let viewModel = OnBoardingViewModel()
//        let viewController = OnBoardingViewController()
//        viewController.viewModel = viewModel
//        viewController.configure(page: page)
//        navigationController.viewControllers = [viewController]
    }
}
