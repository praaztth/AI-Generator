//
//  VideoResultCoordinator.swift
//  AI-Generator
//
//  Created by катенька on 23.06.2025.
//

import Foundation
import RxSwift
import UIKit

class VideoResultCoordinator: BaseCoordinator {
    private let videoURL: URL
    private let storageService: UserDefaultsServiceProtocol
    
    init(videoURL: URL, navigationController: UINavigationController, storageService: UserDefaultsServiceProtocol) {
        self.videoURL = videoURL
        self.storageService = storageService
        super.init(navigationController: navigationController)
    }
    
    override func start() {
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
        
        viewModel.shouldShowLoading
            .drive(onNext: { isLoadNeeded in
                self.setActivityLoading(from: viewController, isShowen: isLoadNeeded)
            })
            .disposed(by: disposeBag)
    }
    
    override func finish() {
//        navigationController.popViewController(animated: true)
        didFinish.onNext(())
    }
}
