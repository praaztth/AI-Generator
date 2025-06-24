//
//  AppCoordinator.swift
//  AI-Generator
//
//  Created by катенька on 17.06.2025.
//

import Foundation
import UIKit
import RxSwift

final class AppCoordinator: CoordinatorProtocol {
    let window: UIWindow
    
    var childCoordinators: [CoordinatorProtocol] = []
    let apiService: PixVerseAPIServiceProtocol
    var storageService: UserDefaultsServiceProtocol
    
    var didFinish = PublishSubject<Void>()
    let disposeBag = DisposeBag()
    
    init(apiService: PixVerseAPIServiceProtocol, storageService: UserDefaultsServiceProtocol, window: UIWindow) {
        self.apiService = apiService
        self.storageService = storageService
        self.window = window
    }
    
    func start() {
        // TODO: change storageService.hasCompletedOnboarding
        if !storageService.hasCompletedOnboarding {
            goToOnBoarding()
        } else {
            goToTabBar()
        }
        
        checkPendingRequests()
    }
    
    func finish() {}
    
    func goToOnBoarding() {
        let coordinator = OnBoardingCoordinator()
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
    
    func goToExploreTemplates(shouldShowPaywall: Bool = false) {
        let coordinator = ExploreTemplatesCoordinator(apiService: apiService, storageService: storageService)
        coordinator.start()
        if shouldShowPaywall {
            coordinator.showPaywall()
        }
        childCoordinators.append(coordinator)
        
        window.rootViewController = coordinator.navigationController
        window.makeKeyAndVisible()
    }
    
    func goToTabBar(showPaywall: Bool = false) {
        let coordinator = TabBarCoordinator(apiService: apiService, storageService: storageService)
        coordinator.start()
        
        childCoordinators.append(coordinator)
        
        window.rootViewController = coordinator.tabBarController
        window.makeKeyAndVisible()
        
        if showPaywall {
            coordinator.showPayWall()
        }
    }
    
    // TODO: move to some layer
    func checkPendingRequests() {
        let requests = storageService.getAllRequests()
        requests.map { $0.video_id }
            .forEach { videoID in
                Observable<Int>.interval(.seconds(5), scheduler: ConcurrentDispatchQueueScheduler(qos: .background))
                    .flatMapLatest { _ in
                        self.apiService.checkPendingRequest(requestID: String(describing: videoID))
                            .catch { error in
                                Observable.empty()
                            }
                    }
                    .take(while: { generatedVideo in
                        generatedVideo.status != "success"
                    })
                    .subscribe(onNext: { responce in
                        print(responce.status)
                    }, onCompleted: {
                        print("\(#file): \(#function): on comleted, removing generation request")
                        self.storageService.removeRequest(videoID: videoID)
                    })
                    .disposed(by: disposeBag)
            }
    }
}
