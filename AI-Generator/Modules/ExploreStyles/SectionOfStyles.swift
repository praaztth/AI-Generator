//
//  SectionOfStylesModel.swift
//  AI-Generator
//
//  Created by катенька on 25.06.2025.
//

import RxDataSources

struct SectionOfStyles {
    var items: [Style]
}

extension SectionOfStyles: SectionModelType {
    typealias Item = Style
    
    init(original: SectionOfStyles, items: [Item]) {
        self = original
        self.items = items
    }
}
