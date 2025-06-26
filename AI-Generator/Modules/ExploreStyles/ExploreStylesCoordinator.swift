//
//  ExploreStylesCoordinator.swift
//  AI-Generator
//
//  Created by катенька on 25.06.2025.
//

import Foundation
import RxSwift
import RxCocoa
import UIKit

class ExploreStyleCoordinator: BaseCoordinator {
//    private let disposeBag = DisposeBag()
    
//    var childCoordinators = [CoordinatorProtocol]()
//    var didFinish = PublishSubject<Void>()
    
    private let _shouldOpenPaywall = PublishRelay<Void>()
    var shouldOpenPaywall: Driver<Void> {
        _shouldOpenPaywall.asDriver(onErrorJustReturn: ())
    }
    
    let apiService: PixVerseAPIServiceProtocol
    let storageService: UserDefaultsServiceProtocol
//    var navigationController = UINavigationController()
    
    init(apiService: PixVerseAPIServiceProtocol, storageService: UserDefaultsServiceProtocol, navigationController: UINavigationController) {
        self.apiService = apiService
        self.storageService = storageService
        super.init(navigationController: navigationController)
    }
    
    override func start() {
        let viewModel = ExploreStylesViewModel(apiService: apiService, storageService: storageService, cacheService: CacheService.shared)
        let viewController = ExploreStylesViewController(viewModel: viewModel)
        navigationController.viewControllers = [viewController]
        
        let viewModelOutput = viewModel as ExploreStylesViewModelToCoordinator
        viewModelOutput.shouldOpenStyle
            .drive(onNext: { style in
                self.goToStyle(style: style)
            })
            .disposed(by: disposeBag)
        
        viewModel.output.didTapOpenPaywall
            .bind(to: _shouldOpenPaywall)
            .disposed(by: disposeBag)
    }
    
    func goToStyle(style: Style) {
        let coordinator = UseStyleCoordinator(apiService: apiService, storageService: storageService, navigationController: navigationController, style: style)
        coordinator.start()
        childCoordinators.append(coordinator)
        
        coordinator.didFinish
            .subscribe(onNext: {
                self.childDidFinished(child: coordinator)
            })
            .disposed(by: disposeBag)
        
        coordinator.shouldOpenPaywall
            .bind(to: _shouldOpenPaywall)
            .disposed(by: disposeBag)
    }
    
    override func finish() {}
}
