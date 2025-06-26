//
//  TabBarCoordinator.swift
//  AI-Generator
//
//  Created by катенька on 24.06.2025.
//

import Foundation
import RxSwift

class TabBarCoordinator: BaseCoordinator {
//    var childCoordinators = [CoordinatorProtocol]()
//    var didFinish = PublishSubject<Void>()
    
    let tabBarController = UITabBarController()
//    private let disposeBag = DisposeBag()
    
    let apiService: PixVerseAPIServiceProtocol
    var storageService: UserDefaultsServiceProtocol
    
    init(apiService: PixVerseAPIServiceProtocol, storageService: UserDefaultsServiceProtocol, navigationController: UINavigationController) {
        self.apiService = apiService
        self.storageService = storageService
        super.init(navigationController: navigationController)
    }
    
    override func start() {
        configureTabBarController()
        
        let templatesExploreCoordinator = ExploreTemplatesCoordinator(apiService: apiService, storageService: storageService, navigationController: UINavigationController())
        let stylesExploreCoordinator = ExploreStyleCoordinator(apiService: apiService, storageService: storageService, navigationController: UINavigationController())
        let usePromptCoordinator = UsePromptCoordinator(apiService: apiService, storageService: storageService, navigationController: UINavigationController())
        let profileCoordinator = ProfileCoordinator(apiService: apiService, storageService: storageService, navigationController: UINavigationController())
        
        templatesExploreCoordinator.start()
        stylesExploreCoordinator.start()
        usePromptCoordinator.start()
        profileCoordinator.start()
        
        let templatesExploreViewController = templatesExploreCoordinator.navigationController
        let stylesExploreViewController = stylesExploreCoordinator.navigationController
        let usePromptViewController = usePromptCoordinator.navigationController
        let profileViewController = profileCoordinator.navigationController
        
        templatesExploreViewController.tabBarItem = UITabBarItem(title: "Templates", image: UIImage(systemName: "photo.fill.on.rectangle.fill"), tag: 0)
        stylesExploreViewController.tabBarItem = UITabBarItem(title: "Styles", image: UIImage(systemName: "play.rectangle.on.rectangle.fill"), tag: 1)
        usePromptViewController.tabBarItem = UITabBarItem(title: "AI Promt", image: UIImage(systemName: "sparkles"), tag: 2)
        profileViewController.tabBarItem = UITabBarItem(title: "Profile", image: UIImage(systemName: "person.fill"), tag: 3)
        
        tabBarController.viewControllers = [templatesExploreViewController, stylesExploreViewController, usePromptViewController, profileViewController]
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
        
        stylesExploreCoordinator.shouldOpenPaywall
            .drive(onNext: {
                self.showPayWall()
            })
            .disposed(by: disposeBag)
        
        profileCoordinator.shouldOpenPaywall
            .drive(onNext: {
                self.showPayWall()
            })
            .disposed(by: disposeBag)
    }
    
    // TODO: move to BaseController and call from each modules separeted
    func showPayWall() {
        let navigationController = UINavigationController()
        let coordinator = PaywallCoordinator(navigationController: navigationController)
        coordinator.start()
        childCoordinators.append(coordinator)
        
        tabBarController.present(navigationController, animated: true)
        
        coordinator.didFinish.subscribe(onNext: {
            self.tabBarController.dismiss(animated: true)
            self.childDidFinished(child: coordinator)
        }).disposed(by: disposeBag)
    }
    
    override func finish() {}
    
    private func configureTabBarController() {
        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = .black
        
        tabBarController.tabBar.standardAppearance = appearance
        tabBarController.tabBar.unselectedItemTintColor = .appPaleGrey30
    }
}
