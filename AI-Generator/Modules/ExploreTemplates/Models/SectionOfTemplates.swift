//
//  SectionOfTemplates.swift
//  AI-Generator
//
//  Created by катенька on 20.06.2025.
//

import RxDataSources

enum TemplateItem {
    case template(Template)
    case style(Style)
}

struct SectionOfTemplates {
    var header: String
    var items: [Item]
}

extension SectionOfTemplates: SectionModelType {
    typealias Item = TemplateItem
    
    init(original: SectionOfTemplates, items: [TemplateItem]) {
        self = original
        self.items = items
    }
    
    
}
