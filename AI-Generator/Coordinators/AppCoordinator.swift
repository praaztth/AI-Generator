//
//  AppCoordinator.swift
//  AI-Generator
//
//  Created by катенька on 17.06.2025.
//

import Foundation
import UIKit
import RxSwift

protocol CoordinatorProtocol: AnyObject {
    var childCoordinators: [CoordinatorProtocol] { get set }
    var navigationController: UINavigationController { get set }
    var didFinish: PublishSubject<Void> { get }
    func childDidFinished(child: CoordinatorProtocol)
    
    func start()
    func finish()
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
    let apiService: PixVerseAPIServiceProtocol
    var storageService: UserDefaultsServiceProtocol
    
    var didFinish = PublishSubject<Void>()
    let disposeBag = DisposeBag()
    
    init(apiService: PixVerseAPIServiceProtocol, storageService: UserDefaultsServiceProtocol, navigationController: UINavigationController) {
        self.apiService = apiService
        self.storageService = storageService
        self.navigationController = navigationController
    }
    
    func start() {
        // TODO: change storageService.hasCompletedOnboarding
        if !storageService.hasCompletedOnboarding {
            goToOnBoarding()
        } else {
            goToExploreTemplates()
        }
        
        checkPendingRequests()
    }
    
    func finish() {}
    
    func goToOnBoarding() {
        let coordinator = OnBoardingCoordinator(navigationController: navigationController)
        coordinator.start()
        childCoordinators.append(coordinator)
        
        coordinator.didFinish.subscribe(onNext: {
            self.storageService.hasCompletedOnboarding = true
            self.goToExploreTemplates(shouldShowPaywall: true)
            self.childDidFinished(child: coordinator)
            
        }).disposed(by: disposeBag)
    }
    
    func goToExploreTemplates(shouldShowPaywall: Bool = false) {
        let coordinator = ExploreTemplatesCoordinator(apiService: apiService, storageService: storageService, navigationController: navigationController)
        coordinator.start()
        if shouldShowPaywall {
            coordinator.showPaywall()
        }
        childCoordinators.append(coordinator)
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
