//
//  UseEffectsCoordinator.swift
//  AI-Generator
//
//  Created by катенька on 20.06.2025.
//

import UIKit
import RxSwift
import RxCocoa

// TODO: separate to two different modules
final class UseEffectsCoordinator: CoordinatorProtocol {
    var childCoordinators: [CoordinatorProtocol] = []
    var navigationController: UINavigationController
    private let effectID: Int
    private let apiService: PixVerseAPIServiceProtocol
    private let storageService: UserDefaultsServiceProtocol
    private var viewModel: UseEffectViewModelProtocol?
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
        viewModel = UseEffectViewModel(effectID: self.effectID, apiService: apiService, storageSevice: storageService, cacheService: CacheService.shared)
        let viewController = UseEffectViewController(viewModel: viewModel!)
        navigationController.pushViewController(viewController, animated: true)
        
//        viewModel?.showLoading
//            .drive { [weak self] _ in
////                self?.navigationController.popViewController(animated: false)
////                self?.didStartGenerationVideo.accept(())
//                self?.goToLoadingView()
//            }
//            .disposed(by: disposeBag)
        
//        viewModel?.generationFinished
//            .drive { [weak self] url in
////                guard let url = URL(string: url) else { return }
////                self?.didCompleteGenerationVideo.onNext(url)
//                guard let self = self else { return }
//                if self.shouldOpenResultView {
//                    self.goToResultView(videoURL: url)
//                }
//            }
//            .disposed(by: disposeBag)
        
        viewModel?.didCloseView
            .subscribe(onNext: { value in
                self.shouldOpenResultView = !value
                if value {
                    self.navigationController.popToRootViewController(animated: false)
                }
            })
            .disposed(by: disposeBag)
        
        viewModel?.shouldGenerateVideo
            .drive { generateBy in
                self.goToVideoGeneration(generateBy: generateBy)
            }
            .disposed(by: disposeBag)
    }
    
    func finish() {
        didFinish.onNext(())
    }
    
    func goToVideoGeneration(generateBy: GenerateBy) {
        let coordinator = VideoGenerationCoordinator(navigationController: navigationController, apiService: apiService, storageService: storageService, generateBy: generateBy)
        coordinator.start()
        childCoordinators.append(coordinator)
        
        coordinator.didFinish.subscribe(onNext: {
            self.childDidFinished(child: coordinator)
        }).disposed(by: disposeBag)
    }
    
    func goToLoadingView() {
        let viewController = VideoGenerationProcessViewController(viewModel: viewModel!)
        navigationController.pushViewController(viewController, animated: true)
    }
    
    func goToResultView(videoURL: URL) {
        let coordinator = VideoResultCoordinator(videoURL: videoURL, navigationController: navigationController, storageService: storageService)
        coordinator.start()
        childCoordinators.append(coordinator)
        
        coordinator.didFinish.subscribe(onNext: {
            self.childDidFinished(child: coordinator)
        }).disposed(by: disposeBag)
    }
}
