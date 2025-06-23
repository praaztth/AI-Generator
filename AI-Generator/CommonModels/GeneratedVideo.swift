//
//  GeneratedVideo.swift
//  AI-Generator
//
//  Created by катенька on 22.06.2025.
//

import Foundation

struct GeneratedVideo: Codable {
    var status: String
    let video_url: String?
    
    mutating func setStatus(_ status: String) {
        self.status = status
    }
}
