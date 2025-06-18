//
//  UserDefaultsService.swift
//  AI-Generator
//
//  Created by катенька on 18.06.2025.
//

import Foundation

protocol UserDefaultsServiceProtocol {
    var hasCompletedOnboarding: Bool { get set }
}

final class UserDefaultsService: UserDefaultsServiceProtocol {
    let hasCompletedOnboardingKey = "hasCompletedOnboarding"
    
    var hasCompletedOnboarding: Bool {
        get { UserDefaults.standard.bool(forKey: hasCompletedOnboardingKey) }
        set { UserDefaults.standard.set(newValue, forKey: hasCompletedOnboardingKey) }
    }
}
