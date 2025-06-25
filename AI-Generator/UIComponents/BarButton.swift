//
//  OpenPaywallButton.swift
//  AI-Generator
//
//  Created by катенька on 18.06.2025.
//

import UIKit

class BarButton: UIButton {
    init(title: String, backgroundColor: UIColor, image: UIImage?) {
        super.init(frame: .zero)
        configure(title: title, backgroundColor: backgroundColor, image: image)
//        setupUI()
    }
    
    func configure(title: String, backgroundColor: UIColor, image: UIImage?) {
        var config = UIButton.Configuration.filled()
        config.cornerStyle = .capsule
        config.baseBackgroundColor = backgroundColor
        config.baseForegroundColor = .white
        config.titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer { incoming in
            var outgoing = incoming
            outgoing.font = UIFont.systemFont(ofSize: 11)
            return outgoing
        }
        configuration = config
        
        setTitle(title, for: .normal)
        setImage(image, for: .normal)
    }
    
    func setupUI() {
        let image = UIImage(systemName: "sparkles")
        setImage(image, for: .normal)
        setTitle("PRO", for: .normal)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
