//
//  SettingsCoordinator.swift
//  AI-Generator
//
//  Created by катенька on 25.06.2025.
//

import Foundation
import RxSwift
import RxCocoa
import SafariServices

class SettingsCoordinator: BaseCoordinator {
//    private let disposeBag = DisposeBag()
//    
//    var childCoordinators = [CoordinatorProtocol]()
//    var didFinish = PublishSubject<Void>()
    
    private let _shouldOpenPaywall = PublishRelay<Void>()
    var shouldOpenPaywall: Observable<Void> {
        _shouldOpenPaywall.asObservable()
    }
    
    let storageService: UserDefaultsServiceProtocol
//    var navigationController: UINavigationController
    
    init(storageService: UserDefaultsServiceProtocol, navigationController: UINavigationController) {
        self.storageService = storageService
        super.init(navigationController: navigationController)
    }
    
    override func start() {
        let viewModel = SettingsViewModel(storageService: storageService)
        let viewController = SettingsViewController(viewModel: viewModel)
        navigationController.pushViewController(viewController, animated: true)
        
        let viewModelInput = viewModel as SettingsViewModelToCoordinator
        
        viewModelInput.shouldOpenPaywall
            .bind(to: _shouldOpenPaywall)
            .disposed(by: disposeBag)
        
        viewModelInput.shouldOpenLink
            .drive(onNext: { url in
                self.openLink(url: url)
//                let safaryVC = SFSafariViewController(url: url)
//                self.navigationController.present(safaryVC, animated: true)
            })
            .disposed(by: disposeBag)
        
        viewModelInput.shouldShowLoading
            .drive(onNext: { [weak viewController] isLoadNeeded in
                guard let viewController = viewController else { return }
                self.setActivityLoading(from: viewController, isShowen: isLoadNeeded)
            })
            .disposed(by: disposeBag)
    }
    
    override func finish() {}
}
