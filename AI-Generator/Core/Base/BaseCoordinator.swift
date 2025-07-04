//
//  BaseCoordinator.swift
//  AI-Generator
//
//  Created by катенька on 26.06.2025.
//

import UIKit
import RxSwift
import SafariServices

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
    
    func setActivityLoading(from vc: UIViewController, isShowen: Bool) {
        if let sheet = vc.sheetPresentationController {
            sheet.detents = [.medium()]
            sheet.preferredCornerRadius = 20
        }
        
        if isShowen {
            let activityViewController = LoadingActivityViewController()
            activityViewController.modalTransitionStyle = .crossDissolve
            vc.present(activityViewController, animated: true)
        } else {
            vc.dismiss(animated: true)
        }
    }
    
    func openLink(url: URL) {
        let safaryVC = SFSafariViewController(url: url)
        self.navigationController.present(safaryVC, animated: true)
    }
    
    func childDidFinished(child: BaseCoordinator) {
        if let index = childCoordinators.firstIndex(where: { $0 === child }) {
            childCoordinators.remove(at: index)
        }
    }
}
