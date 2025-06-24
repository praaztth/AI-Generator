//
//  UsePromptCoordinator.swift
//  AI-Generator
//
//  Created by катенька on 24.06.2025.
//

import Foundation
import RxSwift
import RxCocoa

class UsePromptCoordinator: CoordinatorProtocol {
    private let disposeBag = DisposeBag()
    private var viewModel: UsePromptViewModel?
    
    var childCoordinators = [CoordinatorProtocol]()
    var didFinish = PublishSubject<Void>()
    let apiService: PixVerseAPIServiceProtocol
    let storageService: UserDefaultsServiceProtocol
    var navigationController = UINavigationController()
    
    // TabBarCoordinator inputs
    private let _shouldOpenPaywall = PublishRelay<Void>()
    var shouldOpenPaywall: Driver<Void> {
        _shouldOpenPaywall.asDriver(onErrorJustReturn: ())
    }
    
    init(apiService: PixVerseAPIServiceProtocol, storageService: UserDefaultsServiceProtocol) {
        self.apiService = apiService
        self.storageService = storageService
    }
    
    func start() {
        viewModel = UsePromptViewModel(apiService: apiService, storageService: storageService)
        let viewController = UsePromptViewController(viewModel: viewModel!)
        navigationController.viewControllers = [viewController]
        
        let viewModelInput = viewModel! as UsePromptViewModelToCoordinator
        viewModelInput.shouldOpenPaywall
            .bind(to: _shouldOpenPaywall)
            .disposed(by: disposeBag)
        
        viewModelInput.shouldGenerateVideo
            .drive { generateBy in
                self.goToVideoGeneration(generateBy: generateBy)
            }
            .disposed(by: disposeBag)
        
    }
    
    func goToVideoGeneration(generateBy: GenerateBy) {
        let coordinator = VideoGenerationCoordinator(navigationController: navigationController, apiService: apiService, storageService: storageService, generateBy: generateBy)
        coordinator.start()
        childCoordinators.append(coordinator)
        
        coordinator.didFinish.subscribe(onNext: {
            self.childDidFinished(child: coordinator)
        }).disposed(by: disposeBag)
    }
    
    func finish() {
        
    }
}
