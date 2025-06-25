//
//  GeneratedVideoCellModel.swift
//  AI-Generator
//
//  Created by катенька on 25.06.2025.
//

import UIKit
import RxDataSources

struct GeneratedVideoCellModel {
    let previewImage: UIImage
    let videoURL: URL
}

struct SectionOfVideos {
    var items: [GeneratedVideoCellModel]
}

extension SectionOfVideos: SectionModelType {
    typealias Item = GeneratedVideoCellModel
    
    init(original: SectionOfVideos, items: [GeneratedVideoCellModel]) {
        self = original
        self.items = items
    }
}
