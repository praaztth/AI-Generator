//
//  UseEffectViewControllerModel.swift
//  AI-Generator
//
//  Created by катенька on 21.06.2025.
//

import Foundation

struct UseEffectModel {
    let title: String
    let templateId: Int
    let videoURL: URL?
    
    static func empty() -> UseEffectModel {
        return .init(
            title: "",
            templateId: 0,
            videoURL: nil
        )
    }
}
