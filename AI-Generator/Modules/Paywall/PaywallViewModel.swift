//
//  PaywallViewModel.swift
//  AI-Generator
//
//  Created by катенька on 18.06.2025.
//

import Foundation
import RxSwift
import RxCocoa
import SwiftHelper
import ApphudSDK

enum SubscriptionPlan {
    case monthly
    case yearly
}

protocol PaywallViewModelInputs {
    var productsDriver: Driver<[PaywallProductModel]> { get }
}

protocol PaywallViewModelOutputs {
    var loadTrigger: PublishRelay<Void> { get }
    var didSelectSubscriptionPlan: PublishRelay<Int> { get }
    var didTapSubscribe: PublishRelay<Void> { get }
    var didTapRestorePurchases: PublishRelay<Void> { get }
    var didTapClose: PublishRelay<Void> { get }
}

protocol PaywallViewModelToView {
    var input: PaywallViewModelInputs { get }
    var output: PaywallViewModelOutputs { get }
}

protocol PaywallViewModelToCoordinator {
    var successfullySubscribed: Driver<Void> { get }
    var unsuccessfullySubscribed: Driver<Void> { get }
    var shouldCloseViewDriver: Driver<Void> { get }
}

class PaywallViewModel: ViewModelConfigurable, PaywallViewModelInputs, PaywallViewModelOutputs, PaywallViewModelToView, PaywallViewModelToCoordinator {
    private var products: [ApphudProduct] = []
    private var selectedProductIndex = 0
    private let disposeBag = DisposeBag()
    
    var input: PaywallViewModelInputs { self }
    var output: PaywallViewModelOutputs { self }
    
    // ViewController Inputs
    private let _productsToDisplay = PublishRelay<[PaywallProductModel]>()
    var productsDriver: Driver<[PaywallProductModel]> {
        _productsToDisplay.asDriver(onErrorJustReturn: [])
    }
    
    // ViewController Outputs
    var loadTrigger = PublishRelay<Void>()
    var didSelectSubscriptionPlan = PublishRelay<Int>()
    var didTapSubscribe = PublishRelay<Void>()
    var didTapRestorePurchases = PublishRelay<Void>()
    var didTapClose = PublishRelay<Void>()
    
    // Coordinator Inputs
    private let _successfullySubscribed = PublishRelay<Void>()
    var successfullySubscribed: Driver<Void> {
        _successfullySubscribed.asDriver(onErrorJustReturn: ())
    }
    
    private let _unsuccessfullySubscribed = PublishRelay<Void>()
    var unsuccessfullySubscribed: Driver<Void> {
        _unsuccessfullySubscribed.asDriver(onErrorJustReturn: ())
    }
    
    private let _shouldCloseView = PublishRelay<Void>()
    var shouldCloseViewDriver: Driver<Void> {
        _shouldCloseView.asDriver(onErrorJustReturn: ())
    }
    
    init() {
        setupBindings()
    }
    
    func setupBindings() {
        loadTrigger
            .subscribe(onNext: {
                self.getProducts()
            })
            .disposed(by: disposeBag)
        
        didSelectSubscriptionPlan
            .subscribe(onNext: { index in
                self.selectedProductIndex = index
                print(index)
            })
            .disposed(by: disposeBag)
        
        didTapSubscribe
            .subscribe(onNext: {
                self.purchaseSubscription()
            })
            .disposed(by: disposeBag)
        
        didTapRestorePurchases
            .subscribe(onNext: {
                self.restorePurchases()
            })
            .disposed(by: disposeBag)
        
        didTapClose
            .bind(to: _shouldCloseView)
            .disposed(by: disposeBag)
    }
    
    func getProducts() {
        let formattedNames = [
            "day": "Daily",
            "week": "Weekly",
            "month": "Monthly",
            "year": "Yearly"
        ]
        
        DispatchQueue.main.async {
            SwiftHelper.apphudHelper.fetchProducts(paywallID: "main") { products in
                self.products = products
                
                let productsToDisplay = products.map { product in
                    let unit = SwiftHelper.apphudHelper.returnSubscriptionUnit(product: product) ?? "???"
                    let formattedName = formattedNames[unit] ?? unit.capitalized
                    let (price, symbol) = SwiftHelper.apphudHelper.returnClearPriceAndSymbol(product: product)
                    let perUnit = "per \(unit)"
                    let description = "Just \(symbol)\(price) \(perUnit)"
                    let formattedPrice = symbol + String(price)
                    
                    return PaywallProductModel(name: formattedName, price: formattedPrice, description: description, paymentPeriod: perUnit)
                }
                
                self._productsToDisplay.accept(productsToDisplay)
            }
        }
    }
    
    func purchaseSubscription() {
        let product = products[selectedProductIndex]
        DispatchQueue.main.async { [weak self] in
            SwiftHelper.apphudHelper.purchaseSubscription(subscription: product) { isSuccess in
                if isSuccess {
                    self?._successfullySubscribed.accept(())
                } else {
                    self?._unsuccessfullySubscribed.accept(())
                }
            }
        }
    }
    
    func restorePurchases() {
        DispatchQueue.main.async { [weak self] in
            SwiftHelper.apphudHelper.restoreAllProducts { [weak self] isSuccess in
                if isSuccess {
                    self?._successfullySubscribed.accept(())
                } else {
                    self?._unsuccessfullySubscribed.accept(())
                }
            }
        }
    }
}
