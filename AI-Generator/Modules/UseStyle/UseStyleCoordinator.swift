//
//  UseStyleCoordinator.swift
//  AI-Generator
//
//  Created by катенька on 25.06.2025.
//

import Foundation
import RxSwift

class UseStyleCoordinator: CoordinatorProtocol {
    private let disposeBag = DisposeBag()
    
    var childCoordinators = [CoordinatorProtocol]()
    var didFinish = PublishSubject<Void>()
    
    let apiService: PixVerseAPIServiceProtocol
    let storageService: UserDefaultsServiceProtocol
    var navigationController: UINavigationController
    
    init(apiService: PixVerseAPIServiceProtocol, storageService: UserDefaultsServiceProtocol, navigationController: UINavigationController) {
        self.apiService = apiService
        self.storageService = storageService
        self.navigationController = navigationController
    }
    
    func start() {
        let viewModel = ProfileViewModel(apiService: apiService, storageService: storageService)
        let viewController = ProfileViewController(viewModel: viewModel)
        navigationController.viewControllers = [viewController]
    }
    
    func finish() {
        
    }
}
