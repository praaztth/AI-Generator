//
//  TabBarCoordinator.swift
//  AI-Generator
//
//  Created by катенька on 24.06.2025.
//

import Foundation
import RxSwift

class TabBarCoordinator: CoordinatorProtocol {
    var childCoordinators = [CoordinatorProtocol]()
    var didFinish = PublishSubject<Void>()
    
    let tabBarController = UITabBarController()
    private let disposeBag = DisposeBag()
    
    let apiService: PixVerseAPIServiceProtocol
    var storageService: UserDefaultsServiceProtocol
    
    init(apiService: PixVerseAPIServiceProtocol, storageService: UserDefaultsServiceProtocol) {
        self.apiService = apiService
        self.storageService = storageService
    }
    
    func start() {
        configureTabBarController()
        
        let templatesExploreCoordinator = ExploreTemplatesCoordinator(apiService: apiService, storageService: storageService)
        let usePromptCoordinator = UsePromptCoordinator(apiService: apiService, storageService: storageService)
        let profileCoordinator = ProfileCoordinator(apiService: apiService, storageService: storageService, navigationController: UINavigationController())
        
        templatesExploreCoordinator.start()
        usePromptCoordinator.start()
        profileCoordinator.start()
        
        let templatesExploreViewController = templatesExploreCoordinator.navigationController
        let usePromptViewController = usePromptCoordinator.navigationController
        let profileViewController = profileCoordinator.navigationController
        
        templatesExploreViewController.tabBarItem = UITabBarItem(title: "AI Video", image: UIImage(systemName: "play.rectangle.on.rectangle.fill"), tag: 0)
        usePromptViewController.tabBarItem = UITabBarItem(title: "Promt", image: UIImage(systemName: "sparkles"), tag: 1)
        profileViewController.tabBarItem = UITabBarItem(title: "Profile", image: UIImage(systemName: "person.fill"), tag: 2)
        
        tabBarController.viewControllers = [templatesExploreViewController, usePromptViewController, profileViewController]
        childCoordinators = [templatesExploreCoordinator, usePromptCoordinator, profileCoordinator]
        
        templatesExploreCoordinator.openPaywallEvent
            .drive(onNext: {
                self.showPayWall()
            })
            .disposed(by: disposeBag)
        
        usePromptCoordinator.shouldOpenPaywall
            .drive(onNext: {
                self.showPayWall()
            })
            .disposed(by: disposeBag)
    }
    
    func showPayWall() {
        let coordinator = PaywallCoordinator()
        coordinator.start()
        childCoordinators.append(coordinator)
        
        tabBarController.present(coordinator.viewController!, animated: true)
        
        coordinator.didFinish.subscribe(onNext: {
            coordinator.viewController?.dismiss(animated: true)
            self.childDidFinished(child: coordinator)
        }).disposed(by: disposeBag)
    }
    
    func finish() {
        
    }
    
    private func configureTabBarController() {
        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = .black
        
        tabBarController.tabBar.standardAppearance = appearance
        tabBarController.tabBar.unselectedItemTintColor = .appPaleGrey30
    }
}
