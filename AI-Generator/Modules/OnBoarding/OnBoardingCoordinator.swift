//
//  OnBoardingCoordinator.swift
//  AI-Generator
//
//  Created by катенька on 17.06.2025.
//

import UIKit
import RxSwift
import RxCocoa
import StoreKit

class OnBoardingCoordinator: CoordinatorProtocol {
    var childCoordinators: [CoordinatorProtocol] = []
    var navigationController = UINavigationController()
    let currentPageIndex = BehaviorRelay(value: 0)
    var didFinish = PublishSubject<Void>()
    let disposeBag = DisposeBag()
    
    let pages: [OnBoardingPageModel] = [
        OnBoardingPageModel(title: "AI Power", description: "Unleash the power of imagination - turn moments into art with AI", imageName: "onboarding1"),
        OnBoardingPageModel(title: "AI Tools", description: "Generate photos and videos by writing text promts or uploading media", imageName: "onboarding2"),
        OnBoardingPageModel(title: "AI Templates", description: "Turn any photo into a social media hit with our library of vibrant video template", imageName: "onboarding3")
    ]
    
    func start() {
        currentPageIndex.subscribe(onNext: { index in
            let page = self.pages[index]
            
            let viewModel = OnBoardingViewModel()
            viewModel.didTapNext.subscribe { _ in
                self.goToNextPage()
            }.disposed(by: self.disposeBag)
            
            let viewController = OnBoardingViewController(viewModel: viewModel)
            viewController.configure(title: page.title, description: page.description, imageName: page.imageName)
            
            self.navigationController.viewControllers = [viewController]
        }).disposed(by: disposeBag)
    }
    
    func finish() {
        didFinish.onNext(())
    }
    
    func goToNextPage() {
        if currentPageIndex.value <= pages.count - 2 {
            currentPageIndex.accept(currentPageIndex.value + 1)
        } else {
            let viewModel = OnBoardingAlertViewModel()
            viewModel.didTapNext.subscribe { _ in
                self.goToRateAlert()
            }.disposed(by: disposeBag)
            
            viewModel.didTapCancel.subscribe { _ in
                self.finish()
            }.disposed(by: disposeBag)
            
            let viewController = OnBoardingAlertViewController(viewModel: viewModel)
            viewController.configure(title: "Do you like our app?", description: "Please rate our app so we can improve it for ypu and make it even cooler", imageName: "paywallBackground")
            
            self.navigationController.viewControllers = [viewController]
        }
    }
    
    func goToRateAlert() {
        DispatchQueue.main.async {
            guard let scene = UIApplication.shared.connectedScenes.first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene else {
                return
            }
            AppStore.requestReview(in: scene)
            self.finish()
        }
    }
}
