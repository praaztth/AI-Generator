//
//  PaywallViewModel.swift
//  AI-Generator
//
//  Created by катенька on 18.06.2025.
//

import Foundation
import RxSwift

enum SubscriptionPlan {
    case monthly
    case yearly
}

class PaywallViewModel: PaywallViewControllerOutput {
    var selectedSubscriptionPlan: SubscriptionPlan = .monthly
    
    func didSelectedUpperButton() {
        selectedSubscriptionPlan = .monthly
        print("Monthly subscription plan selected")
    }
    
    func didSelectedLowerButton() {
        selectedSubscriptionPlan = .yearly
        print("Yearly subscription plan selected")
    }
    
    func didTappedSubscribeButton() {
        print("Subscribe button tapped")
    }
}
