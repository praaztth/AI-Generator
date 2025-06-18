//
//  ExploreTemplatesViewModel.swift
//  AI-Generator
//
//  Created by катенька on 18.06.2025.
//

import RxCocoa

class ExploreTemplatesViewModel: ExploreTemplatesViewControllerOutput {
    let openPaywallEvent = PublishRelay<Void>()
    
    func didTapOpenPaywall() {
        openPaywallEvent.accept(())
    }
}
