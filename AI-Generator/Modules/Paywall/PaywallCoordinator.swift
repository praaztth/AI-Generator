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
    var viewController: UIViewController?
    var didFinish = PublishSubject<Void>()
    let disposedBag = DisposeBag()
    
    func start() {
        let viewModel = PaywallViewModel()
        viewController = PaywallViewController(viewModel: viewModel)
        viewController?.modalPresentationStyle = .fullScreen
        
        viewModel.didTapSubscribeButton.subscribe(onNext: {
            self.finish()
        }).disposed(by: disposedBag)
    }
    
    func finish() {
        didFinish.onNext(())
    }
}
