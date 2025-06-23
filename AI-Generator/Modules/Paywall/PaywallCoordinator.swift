//
//  PaywallCoordinator.swift
//  AI-Generator
//
//  Created by катенька on 17.06.2025.
//

import UIKit
import RxSwift

class PaywallCoordinator: CoordinatorProtocol {
    var childCoordinators: [CoordinatorProtocol] = []
    var navigationController: UINavigationController
    var didFinish = PublishSubject<Void>()
    let disposedBag = DisposeBag()
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    func start() {
        let viewModel = PaywallViewModel()
        let viewController = PaywallViewController(viewModel: viewModel)
        navigationController.pushViewController(viewController, animated: true)
        
        viewModel.didTapSubscribeButton.subscribe(onNext: {
            self.finish()
        }).disposed(by: disposedBag)
    }
    
    func finish() {
        navigationController.popViewController(animated: true)
        didFinish.onNext(())
    }
}
