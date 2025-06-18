//
//  PaywallCoordinator.swift
//  AI-Generator
//
//  Created by катенька on 17.06.2025.
//

import UIKit

class PaywallCoordinator: CoordinatorProtocol {
    var childCoordinators: [CoordinatorProtocol] = []
    var navigationController: UINavigationController
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    func start() {
        let viewModel = PaywallViewModel()
        let viewController = PaywallViewController(viewModel: viewModel)
        navigationController.viewControllers = [viewController]
    }
}
