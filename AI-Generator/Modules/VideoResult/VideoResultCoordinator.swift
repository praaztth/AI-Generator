//
//  VideoResultCoordinator.swift
//  AI-Generator
//
//  Created by катенька on 23.06.2025.
//

import Foundation
import RxSwift

class VideoResultCoordinator: CoordinatorProtocol {
    private let videoURL: URL
    private let storageService: UserDefaultsServiceProtocol
    private let disposeBag = DisposeBag()
    
    var childCoordinators: [any CoordinatorProtocol] = []
    var navigationController: UINavigationController
    var didFinish = PublishSubject<Void>()
    
    init(videoURL: URL, navigationController: UINavigationController, storageService: UserDefaultsServiceProtocol) {
        self.videoURL = videoURL
        self.navigationController = navigationController
        self.storageService = storageService
    }
    
    func start() {
        let viewModel = VideoResultViewModel(videoURL: videoURL, storageService: storageService)
        let viewController = VideoResultViewController(viewModel: viewModel)
        navigationController.pushViewController(viewController, animated: false)
        
        viewModel.didCloseView
            .subscribe(onNext: { value in
                if value {
                    self.navigationController.popToRootViewController(animated: true)
                }
            })
            .disposed(by: disposeBag)
    }
    
    func finish() {
//        navigationController.popViewController(animated: true)
        didFinish.onNext(())
    }
}
