//
//  PaywallCoordinator.swift
//  AI-Generator
//
//  Created by катенька on 17.06.2025.
//

import UIKit
import RxSwift
import RxCocoa

class PaywallCoordinator: CoordinatorProtocol {
    var childCoordinators: [CoordinatorProtocol] = []
    let navigationController: UINavigationController
    var didFinish = PublishSubject<Void>()
    let disposedBag = DisposeBag()
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    func start() {
        let viewModel = PaywallViewModel()
        let viewController = PaywallViewController(viewModel: viewModel)
        navigationController.modalPresentationStyle = .fullScreen
        navigationController.viewControllers = [viewController]
        
        let viewModelInput = viewModel as PaywallViewModelToCoordinator
        viewModelInput.successfullySubscribed
            .drive(onNext: { [weak self] in
                self?.finish()
            })
            .disposed(by: disposedBag)
        viewModelInput.unsuccessfullySubscribed
            .drive(onNext: { [weak self] in
                self?.showAlert(message: "Something went wrong with the subscription purchase")
            })
            .disposed(by: disposedBag)
        viewModelInput.shouldCloseViewDriver
            .drive(onNext: {
                self.finish()
            })
            .disposed(by: disposedBag)
    }
    
    func showAlert(message: String) {
        let alertController = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .default))
        navigationController.present(alertController, animated: true)
    }
    
    func finish() {
        didFinish.onNext(())
    }
}
