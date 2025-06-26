//
//  BaseCoordinator.swift
//  AI-Generator
//
//  Created by катенька on 26.06.2025.
//

import UIKit
import RxSwift

class BaseCoordinator {
    var childCoordinators: [BaseCoordinator] = []
    let navigationController: UINavigationController
    let didFinish = PublishSubject<Void>()
    let disposeBag = DisposeBag()
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    func start() { fatalError("\(#function) has not been implemented") }
    
    func finish() { fatalError("\(#function) has not been implemented") }
    
    func showAlert(message: String) {
        let alertController = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .default))
        navigationController.present(alertController, animated: true)
    }
    
    func childDidFinished(child: BaseCoordinator) {
        if let index = childCoordinators.firstIndex(where: { $0 === child }) {
            childCoordinators.remove(at: index)
        }
    }
}
