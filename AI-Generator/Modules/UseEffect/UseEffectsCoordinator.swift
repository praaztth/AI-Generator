//
//  UseEffectsCoordinator.swift
//  AI-Generator
//
//  Created by катенька on 20.06.2025.
//

import UIKit
import RxSwift
import RxCocoa

final class UseEffectsCoordinator: BaseCoordinator {
//    var childCoordinators: [CoordinatorProtocol] = []
//    var navigationController: UINavigationController
    private let effectID: Int
    private let apiService: PixVerseAPIServiceProtocol
    private let storageService: UserDefaultsServiceProtocol
    private var viewModel: UseEffectViewModelProtocol?
//    private let disposeBag = DisposeBag()
    
    private var shouldOpenResultView = true
    
//    var didFinish = PublishSubject<Void>()
    
    private let _shouldOpenPaywall = PublishRelay<Void>()
    var shouldOpenPaywall: Observable<Void> {
        _shouldOpenPaywall.asObservable()
    }
    
    init(effectID: Int, apiService: PixVerseAPIServiceProtocol, storageService: UserDefaultsServiceProtocol, navigationController: UINavigationController) {
        self.effectID = effectID
        self.apiService = apiService
        self.storageService = storageService
        super.init(navigationController: navigationController)

//        self.navigationController = navigationController
    }
    
    override func start() {
        viewModel = UseEffectViewModel(effectID: self.effectID, apiService: apiService, storageSevice: storageService, cacheService: CacheService.shared)
        let viewController = UseEffectViewController(viewModel: viewModel!)
        navigationController.pushViewController(viewController, animated: true)
        
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
        
        viewModel?.shouldShowAlert
            .drive(onNext: { text in
                self.showAlert(message: text)
            })
            .disposed(by: disposeBag)
        
        viewModel?.shouldOpenPaywall
            .bind(to: _shouldOpenPaywall)
            .disposed(by: disposeBag)
    }
    
//    func showAlert(message: String) {
//        let alertController = UIAlertController(title: nil, message: message, preferredStyle: .alert)
//        alertController.addAction(UIAlertAction(title: "OK", style: .default))
//        navigationController.present(alertController, animated: true)
//    }
    
    override func finish() {
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
}
