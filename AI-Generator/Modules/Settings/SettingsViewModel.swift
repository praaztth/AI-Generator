//
//  SettingsViewModel.swift
//  AI-Generator
//
//  Created by катенька on 25.06.2025.
//

import Foundation
import RxSwift
import RxCocoa
import StoreKit
import ApphudSDK

protocol SettingsViewModelInputs {
    var itemsToDisplay: BehaviorRelay<[String]> { get }
}

protocol SettingsViewModelOutputs {
    var didTapOpenPaywall: PublishRelay<Void> { get }
    var didTapItem: PublishRelay<String> { get }
}

protocol SettingsViewModelToView {
    var input: SettingsViewModelInputs { get }
    var output: SettingsViewModelOutputs { get }
}

protocol SettingsViewModelToCoordinator: ViewModelToCoordinator {
    var shouldOpenPaywall: Observable<Void> { get }
    var shouldOpenLink: Driver<URL> { get }
//    var shouldShowLoading: Driver<Bool> { get }
}

enum SettingItems: String, CaseIterable {
    case rateUs = "Rate us"
    case share = "Share to friends"
    case push = "Push Notifications"
    case privacy = "Privacy Policy"
    case terms = "Terms of use"
    case support = "Support"
}

class SettingsViewModel: BaseViewModel, SettingsViewModelInputs, SettingsViewModelOutputs, SettingsViewModelToView, SettingsViewModelToCoordinator {
    private let storageService: UserDefaultsServiceProtocol
    private let disposeBag = DisposeBag()
    
    var input: SettingsViewModelInputs { self }
    var output: SettingsViewModelOutputs { self }
    
    // ViewController Inputs
    var itemsToDisplay = BehaviorRelay<[String]>(value: SettingItems.allCases.map { $0.rawValue })
    
    // ViewController Outputs
    var didTapOpenPaywall = PublishRelay<Void>()
    var didTapItem = PublishRelay<String>()
    
    // Coordinator Inputs
    private let _shouldOpenPaywall = PublishRelay<Void>()
    var shouldOpenPaywall: Observable<Void> {
        _shouldOpenPaywall.asObservable()
    }
    
    private let _shouldOpenLink = PublishRelay<URL>()
    var shouldOpenLink: Driver<URL> {
        _shouldOpenLink.asDriver(onErrorJustReturn: URL(string: "https://example.com")!)
    }
    
//    private let _shouldShowLoading = PublishRelay<Bool>()
//    var shouldShowLoading: Driver<Bool> {
//        _shouldShowLoading.asDriver(onErrorJustReturn: false)
//    }
    
    init(storageService: UserDefaultsServiceProtocol) {
        self.storageService = storageService
        super.init()
    }
    
    override func setupBindings() {
        didTapOpenPaywall
            .bind(to: _shouldOpenPaywall)
            .disposed(by: disposeBag)
        
        didTapItem
            .subscribe(onNext: { string in
                guard let item = SettingItems(rawValue: string) else { return }
                self.handleSelectedItem(item: item)
            })
            .disposed(by: disposeBag)
    }
    
    func handleSelectedItem(item: SettingItems) {
        switch item {
        case .rateUs:
            self.requestReview()
            
        case .privacy:
            guard let url = URL(string: "https://docs.google.com/document/d/1SXO9Nxq_tqP4KulDGQG3N5GuPe6Kb8RhweecGfHVbQM/edit?tab=t.0") else { return }
            _shouldOpenLink.accept(url)
            
        case .terms:
            guard let url = URL(string: "https://docs.google.com/document/d/1O3CZ9Nv7UpGiRnHe_tQZy5TbLbW7BfkvTih-Yb81vWY/edit?tab=t.0") else { return }
            _shouldOpenLink.accept(url)
            
        case .support:
            openLinkToMail()
        default:
            break
        }
    }
    
    func openLinkToMail() {
        _shouldShowLoading.accept(true)
        
        DispatchQueue.main.async { [weak self] in
            let mailTo = "nikolaaabaaabic@outlook.com"
            let stringURL = "mailto:\(mailTo)"
            let userID = Apphud.userID()
            let subject = "App Support".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
            let body = "Apphud User ID: \(userID)".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
            
            guard var url = URL(string: stringURL) else { return }
            url = url.appending(queryItems: [
                URLQueryItem(name: "subject", value: subject),
                URLQueryItem(name: "body", value: body)
            ])
            
            if UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            } else {
                print("Mail app not available")
            }
            
            self?._shouldShowLoading.accept(false)
        }
    }
    
    func requestReview() {
        _shouldShowLoading.accept(true)
        
        DispatchQueue.main.async { [weak self] in
            guard let scene = UIApplication.shared.connectedScenes.first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene else {
                return
            }
            AppStore.requestReview(in: scene)
            
            self?._shouldShowLoading.accept(false)
        }
    }
}
