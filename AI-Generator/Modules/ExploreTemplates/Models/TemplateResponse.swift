//
//  TemplateResponse.swift
//  AI-Generator
//
//  Created by катенька on 20.06.2025.
//

import Foundation

struct TemplateResponse: Codable {
    let app_id: String
    let templates: [Template]
    let styles: [Style]
    let id: Int
}

struct Template: Codable {
    let prompt: String
    let name: String
    let category: String
    let is_active: Bool
    let preview_small: String
    let preview_large: String
    let id: Int
    let template_id: Int
}

struct Style: Codable {
    let prompt: String
    let name: String
    let is_active: Bool
    let preview_small: String
    let preview_large: String
    let id: Int
    let template_id: Int
    
    static func empty() -> Style {
        Style(prompt: "", name: "", is_active: false, preview_small: "", preview_large: "", id: 0, template_id: 0)
    }
}
