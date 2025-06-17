//
//  AppCoordinator.swift
//  AI-Generator
//
//  Created by катенька on 17.06.2025.
//

import UIKit

protocol CoordinatorProtocol: AnyObject {
    var parentCoordinator: CoordinatorProtocol? { get set }
    var childCoordinators: [CoordinatorProtocol] { get set }
    var navigationController: UINavigationController { get set }
    
    func start()
}

final class AppCoordinator: CoordinatorProtocol {
    var parentCoordinator: CoordinatorProtocol?
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
    
    let pages: [OnBoardingPageModel] = [
        OnBoardingPageModel(title: "AI Power", description: "Unleash the power of imagination - turn moments into art with AI", imageName: "onboarding1"),
        OnBoardingPageModel(title: "AI Tools", description: "Generate photos and videos by writing text promts or uploading media", imageName: "onboarding2"),
        OnBoardingPageModel(title: "AI Templates", description: "Turn any photo into a social media hit with our library of vibrant video template", imageName: "onboarding3")
    ]
    
    var currentIndex = 0
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    func start() {
        if !hasCompletedOnboarding {
            navigateToOnBoarding()
        }
    }
    
    func navigateToOnBoarding() {
        let page = pages[currentIndex]
        let viewModel = OnBoardingViewModel()
        let viewController = OnBoardingViewController()
        viewController.viewModel = viewModel
        viewController.configure(page: page)
        navigationController.viewControllers = [viewController]
    }
}
