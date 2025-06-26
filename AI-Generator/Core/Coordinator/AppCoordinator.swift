//
//  AppCoordinator.swift
//  AI-Generator
//
//  Created by катенька on 17.06.2025.
//

import Foundation
import UIKit
import RxSwift
import SwiftHelper
import ApphudSDK

final class AppCoordinator: BaseCoordinator {
    let window: UIWindow
    
    let apiService: PixVerseAPIServiceProtocol
    var storageService: UserDefaultsServiceProtocol
    
    init(apiService: PixVerseAPIServiceProtocol, storageService: UserDefaultsServiceProtocol, window: UIWindow) {
        self.apiService = apiService
        self.storageService = storageService
        self.window = window
        super.init(navigationController: UINavigationController())
    }
    
    override func start() {
//        Apphud.enableDebugLogs()
        DispatchQueue.main.async {
            Apphud.start(apiKey: "app_NRNkc8FMVUrccB1iUNjzNQAA3rZaAQ")
        }
        
        // TODO: change storageService.hasCompletedOnboarding
        if !storageService.hasCompletedOnboarding {
            goToOnBoarding()
        } else {
            goToTabBar()
        }
        
        checkPendingRequests()
    }
    
    override func finish() {}
    
    func goToOnBoarding() {
        let coordinator = OnBoardingCoordinator(navigationController: UINavigationController())
        coordinator.start()
        childCoordinators.append(coordinator)
        
        window.rootViewController = coordinator.navigationController
        window.makeKeyAndVisible()
        
        coordinator.didFinish.subscribe(onNext: {
            self.storageService.hasCompletedOnboarding = true
            self.goToTabBar(showPaywall: true)
            self.childDidFinished(child: coordinator)
            
        }).disposed(by: disposeBag)
    }
    
    func goToTabBar(showPaywall: Bool = false) {
        let coordinator = TabBarCoordinator(apiService: apiService, storageService: storageService, navigationController: UINavigationController())
        coordinator.start()
        
        childCoordinators.append(coordinator)
        
        window.rootViewController = coordinator.tabBarController
        window.makeKeyAndVisible()
        
        if showPaywall {
            coordinator.showPayWall()
        }
    }
    
    func checkPendingRequests() {
        let requests = storageService.getAllRequests()
        requests.map { $0.video_id }
            .forEach { videoID in
                // TODO: move to separate nethod in GenerationFlowHelper
                self.apiService.observeVideoGenerationStatus(videoID: String(videoID))
                    .filter { videoID, generatedVideo in
                        generatedVideo.status == "success" || generatedVideo.status == "error"
                    }
                    .take(1)
                    .subscribe(onNext: { videoID, generatedVideo in
                        if let id = Int(videoID) {
                            self.storageService.removeRequest(videoID: id)
                        }
                        self.storageService.saveGeneratedVideo(generatedVideo)
                    }, onError: { error in
                        print(error)
                    }, onCompleted: {
                        print("\(#file): \(#function): on comleted, removing generation request")
                    })
                    .disposed(by: disposeBag)
            }
    }
}
