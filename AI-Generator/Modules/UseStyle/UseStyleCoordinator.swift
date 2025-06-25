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
    let style: Style
    
    init(apiService: PixVerseAPIServiceProtocol, storageService: UserDefaultsServiceProtocol, navigationController: UINavigationController, style: Style) {
        self.apiService = apiService
        self.storageService = storageService
        self.navigationController = navigationController
        self.style = style
    }
    
    func start() {
        let viewModel = UseStyleViewModel(apiService: apiService, storageService: storageService, style: style)
        let viewController = UseStyleViewController(viewModel: viewModel)
        navigationController.pushViewController(viewController, animated: true)
        
        let viewModelInput = viewModel as UseStylesViewModelToCoordinator
        viewModelInput.shouldGenerateVideo
            .drive(onNext: { generateBy in
                self.goToVideoGeneration(generateBy: generateBy)
            })
            .disposed(by: disposeBag)
    }
    
    func goToVideoGeneration(generateBy: GenerateBy) {
        let coordinator = VideoGenerationCoordinator(navigationController: navigationController, apiService: apiService, storageService: storageService, generateBy: generateBy)
        coordinator.start()
        childCoordinators.append(coordinator)
        
        coordinator.didFinish.subscribe(onNext: {
            self.childDidFinished(child: coordinator)
        }).disposed(by: disposeBag)
    }
    
    func finish() {
        
    }
}
