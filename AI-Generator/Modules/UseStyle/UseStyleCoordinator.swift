//
//  UseStyleCoordinator.swift
//  AI-Generator
//
//  Created by катенька on 25.06.2025.
//

import Foundation
import RxSwift
import RxCocoa
import UIKit

class UseStyleCoordinator: BaseCoordinator {
//    private let disposeBag = DisposeBag()
    
//    var childCoordinators = [CoordinatorProtocol]()
//    var didFinish = PublishSubject<Void>()
    
    private let _shouldOpenPaywall = PublishRelay<Void>()
    var shouldOpenPaywall: Observable<Void> {
        _shouldOpenPaywall.asObservable()
    }
    
    let apiService: PixVerseAPIServiceProtocol
    let storageService: UserDefaultsServiceProtocol
//    var navigationController: UINavigationController
    let style: Style
    
    init(apiService: PixVerseAPIServiceProtocol, storageService: UserDefaultsServiceProtocol, navigationController: UINavigationController, style: Style) {
        self.apiService = apiService
        self.storageService = storageService
//        self.navigationController = navigationController
        self.style = style
        super.init(navigationController: navigationController)
    }
    
    override func start() {
        let viewModel = UseStyleViewModel(apiService: apiService, storageService: storageService, style: style)
        let viewController = UseStyleViewController(viewModel: viewModel)
        navigationController.pushViewController(viewController, animated: true)
        
        let viewModelInput = viewModel as UseStylesViewModelToCoordinator
        viewModelInput.shouldGenerateVideo
            .drive(onNext: { generateBy in
                self.goToVideoGeneration(generateBy: generateBy)
            })
            .disposed(by: disposeBag)
        
        viewModelInput.shouldShowAlert
            .drive(onNext: { text in
                self.showAlert(message: text)
            })
            .disposed(by: disposeBag)
        
        viewModelInput.shouldOpenPaywall
            .bind(to: _shouldOpenPaywall)
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
