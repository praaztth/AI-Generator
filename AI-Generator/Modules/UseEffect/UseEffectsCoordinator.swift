//
//  UseEffectsCoordinator.swift
//  AI-Generator
//
//  Created by катенька on 20.06.2025.
//

import UIKit
import RxSwift
import RxCocoa

final class UseEffectsCoordinator: CoordinatorProtocol {
    var childCoordinators: [CoordinatorProtocol] = []
    var navigationController: UINavigationController
    private let effectID: Int
    private let apiService: PixVerseAPIServiceProtocol
    private let storageService: UserDefaultsServiceProtocol
    private let disposeBag = DisposeBag()
    
    private var shouldOpenResultView = true
    
//    let didStartGenerationVideo = PublishRelay<Void>()
//    let didCompleteGenerationVideo = PublishSubject<URL>()
    var didFinish = PublishSubject<Void>()
    
    init(effectID: Int, apiService: PixVerseAPIServiceProtocol, storageService: UserDefaultsServiceProtocol, navigationController: UINavigationController) {
        self.effectID = effectID
        self.apiService = apiService
        self.storageService = storageService
        self.navigationController = navigationController
    }
    
    func start() {
        let viewModel = UseEffectViewModel(effectID: self.effectID, apiService: apiService, storageSevice: storageService, cacheService: CacheService.shared)
        let viewController = UseEffectViewController(viewModel: viewModel)
        navigationController.pushViewController(viewController, animated: true)
        
        viewModel.showLoading
            .drive { [weak self] _ in
//                self?.navigationController.popViewController(animated: false)
//                self?.didStartGenerationVideo.accept(())
                self?.goToLoadingView()
            }
            .disposed(by: disposeBag)
        
        viewModel.generationFinished
            .drive { [weak self] url in
//                guard let url = URL(string: url) else { return }
//                self?.didCompleteGenerationVideo.onNext(url)
                guard let self = self else { return }
                if self.shouldOpenResultView {
                    self.goToResultView(videoURL: url)
                }
            }
            .disposed(by: disposeBag)
        
        viewModel.didCloseView
            .subscribe(onNext: { value in
                self.shouldOpenResultView = !value
            })
            .disposed(by: disposeBag)
    }
    
    func finish() {
        didFinish.onNext(())
    }
    
    func goToLoadingView() {
        let viewController = VideoGenerationProcessViewController()
        var newViewControllers = navigationController.viewControllers
        newViewControllers.removeLast()
        newViewControllers.append(viewController)
        navigationController.setViewControllers(newViewControllers, animated: false)
//        navigationController.popViewController(animated: false)
//        navigationController.pushViewController(viewController, animated: true)
    }
    
    func goToResultView(videoURL: URL) {
        navigationController.popViewController(animated: false)
        
        let coordinator = VideoResultCoordinator(videoURL: videoURL, navigationController: navigationController, storageService: storageService)
        coordinator.start()
        childCoordinators.append(coordinator)
        
        coordinator.didFinish.subscribe(onNext: {
            self.childDidFinished(child: coordinator)
        }).disposed(by: disposeBag)
    }
}
