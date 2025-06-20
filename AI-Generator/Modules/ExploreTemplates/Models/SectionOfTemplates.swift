//
//  SectionOfTemplates.swift
//  AI-Generator
//
//  Created by катенька on 20.06.2025.
//

import RxDataSources

struct SectionOfTemplates {
    var header: String
    var items: [Item]
}

extension SectionOfTemplates: SectionModelType {
    typealias Item = Template
    
    init(original: SectionOfTemplates, items: [Template]) {
        self = original
        self.items = items
    }
    
    
}
