//
//  ProfileCoordinator.swift
//  AI-Generator
//
//  Created by катенька on 24.06.2025.
//

import Foundation
import RxSwift
import RxCocoa

class ProfileCoordinator: BaseCoordinator {
//    private let disposeBag = DisposeBag()
    
//    var childCoordinators = [CoordinatorProtocol]()
//    var didFinish = PublishSubject<Void>()
    
    let apiService: PixVerseAPIServiceProtocol
    let storageService: UserDefaultsServiceProtocol
//    var navigationController: UINavigationController
    
    private let _shouldOpenPaywall = PublishRelay<Void>()
    var shouldOpenPaywall: Driver<Void> {
        _shouldOpenPaywall.asDriver(onErrorJustReturn: ())
    }
    
    init(apiService: PixVerseAPIServiceProtocol, storageService: UserDefaultsServiceProtocol, navigationController: UINavigationController) {
        self.apiService = apiService
        self.storageService = storageService
        super.init(navigationController: navigationController)
    }
    
    override func start() {
        let viewModel = ProfileViewModel(apiService: apiService, storageService: storageService)
        let viewController = ProfileViewController(viewModel: viewModel)
        navigationController.viewControllers = [viewController]
        
        let viewModelInput = viewModel as ProfileViewModelToCoordinator
        
        viewModelInput.shouldOpenSettings
            .drive(onNext: {
                self.goToSettings()
            })
            .disposed(by: disposeBag)
        
        viewModelInput.shouldOpenVideo
            .drive { url in
                self.goToVideo(videoURL: url)
            }
            .disposed(by: disposeBag)
    }
    
    func goToVideo(videoURL: URL) {
        let coordinator = VideoResultCoordinator(videoURL: videoURL, navigationController: navigationController, storageService: storageService)
        coordinator.start()
        childCoordinators.append(coordinator)
        
        coordinator.didFinish.subscribe(onNext: {
            self.childDidFinished(child: coordinator)
        }).disposed(by: disposeBag)
    }
    
    func goToSettings() {
        let coordinator = SettingsCoordinator(storageService: storageService, navigationController: navigationController)
        coordinator.start()
        childCoordinators.append(coordinator)
        
        coordinator.shouldOpenPaywall
            .subscribe(onNext: {
                self._shouldOpenPaywall.accept(())
            })
            .disposed(by: disposeBag)
        
        coordinator.didFinish
            .subscribe(onNext: { [weak self] in
                self?.childDidFinished(child: coordinator)
            })
            .disposed(by: disposeBag)
    }
    
    override func finish() {}
}
