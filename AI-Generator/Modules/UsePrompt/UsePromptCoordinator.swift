//
//  UsePromptCoordinator.swift
//  AI-Generator
//
//  Created by катенька on 24.06.2025.
//

import Foundation
import RxSwift
import RxCocoa
import UIKit

class UsePromptCoordinator: BaseCoordinator {
//    private let disposeBag = DisposeBag()
//    
//    var childCoordinators = [CoordinatorProtocol]()
//    var didFinish = PublishSubject<Void>()
    let apiService: PixVerseAPIServiceProtocol
    let storageService: UserDefaultsServiceProtocol
//    var navigationController = UINavigationController()
    
    // TabBarCoordinator inputs
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
        let viewModel = UsePromptViewModel(apiService: apiService, storageService: storageService)
        let viewController = UsePromptViewController(viewModel: viewModel)
        navigationController.viewControllers = [viewController]
        
        let viewModelInput = viewModel as UsePromptViewModelToCoordinator
        viewModelInput.shouldOpenPaywall
            .bind(to: _shouldOpenPaywall)
            .disposed(by: disposeBag)
        
        viewModelInput.shouldGenerateVideo
            .drive { generateBy in
                self.goToVideoGeneration(generateBy: generateBy)
            }
            .disposed(by: disposeBag)
        
        viewModelInput.shouldShowAlert
            .drive(onNext: { text in
                self.showAlert(message: text)
            })
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
    
//    func showAlert(message: String) {
//        let alertController = UIAlertController(title: nil, message: message, preferredStyle: .alert)
//        alertController.addAction(UIAlertAction(title: "OK", style: .default))
//        navigationController.present(alertController, animated: true)
//    }
    
    override func finish() {}
}
