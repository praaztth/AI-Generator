//
//  VideoGeneration.swift
//  AI-Generator
//
//  Created by катенька on 24.06.2025.
//

import Foundation
import RxSwift

enum GenerateBy {
    case imageTemplate(imageData: Data, imageName: String, templateID: String)
    case prompt(prompt: String)
    case promptAndImage(imageData: Data, imageName: String, prompt: String)
}

class VideoGenerationCoordinator: CoordinatorProtocol {
    private let apiService: PixVerseAPIServiceProtocol
    private let storageService: UserDefaultsServiceProtocol
    private let generateBy: GenerateBy
    private let disposeBag = DisposeBag()
    
    var childCoordinators: [any CoordinatorProtocol] = []
    var navigationController: UINavigationController
    var didFinish = PublishSubject<Void>()
    
    init(navigationController: UINavigationController, apiService: PixVerseAPIServiceProtocol, storageService: UserDefaultsServiceProtocol, generateBy: GenerateBy) {
        self.navigationController = navigationController
        self.apiService = apiService
        self.storageService = storageService
        self.generateBy = generateBy
    }
    
    func start() {
        let viewModel = VideoGenerationViewModel(apiService: apiService, storageService: storageService, generateBy: generateBy)
        let viewController = VideoGenerationViewController(viewModel: viewModel)
        navigationController.pushViewController(viewController, animated: true)
        
        viewModel.didCloseView
            .subscribe(onNext: {
                DispatchQueue.main.async {
                    self.navigationController.popToRootViewController(animated: true)
                }
            })
            .disposed(by: disposeBag)
        
        viewModel.generationFinished
            .subscribe(onNext: { url in
                self.goToResultView(videoURL: url)
            }) { error in
                DispatchQueue.main.async {
                    self.navigationController.popToRootViewController(animated: true)
                }
            }
            .disposed(by: disposeBag)
    }
    
    func goToResultView(videoURL: URL) {
        let coordinator = VideoResultCoordinator(videoURL: videoURL, navigationController: navigationController, storageService: storageService)
        coordinator.start()
        childCoordinators.append(coordinator)
        
        coordinator.didFinish.subscribe(onNext: {
            self.childDidFinished(child: coordinator)
        }).disposed(by: disposeBag)
    }
    
    func finish() {
        
    }
}
