//
//  VideoGenerationProcessViewController.swift
//  AI-Generator
//
//  Created by катенька on 23.06.2025.
//

import UIKit

class VideoGenerationProcessViewController: UIViewController {
    let activityView = UIActivityIndicatorView(style: .large)
    
    override func viewDidLoad() {
        view.addSubview(activityView)
        activityView.startAnimating()
        
        activityView.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
    }
}
