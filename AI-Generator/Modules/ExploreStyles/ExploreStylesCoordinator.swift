//
//  ExploreStylesCoordinator.swift
//  AI-Generator
//
//  Created by катенька on 25.06.2025.
//

import Foundation
import RxSwift

class ExploreStyleCoordinator: CoordinatorProtocol {
    private let disposeBag = DisposeBag()
    
    var childCoordinators = [CoordinatorProtocol]()
    var didFinish = PublishSubject<Void>()
    
    let apiService: PixVerseAPIServiceProtocol
    let storageService: UserDefaultsServiceProtocol
    var navigationController = UINavigationController()
    
    init(apiService: PixVerseAPIServiceProtocol, storageService: UserDefaultsServiceProtocol) {
        self.apiService = apiService
        self.storageService = storageService
    }
    
    func start() {
        let viewModel = ExploreStylesViewModel(apiService: apiService, storageService: storageService, cacheService: CacheService.shared)
        let viewController = ExploreStylesViewController(viewModel: viewModel)
        navigationController.viewControllers = [viewController]
    }
    
    func finish() {
        
    }
}
