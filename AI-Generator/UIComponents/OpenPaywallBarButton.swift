//
//  OpenPaywallButton.swift
//  AI-Generator
//
//  Created by катенька on 18.06.2025.
//

import UIKit

class OpenPaywallBarButton: UIButton {
    init() {
        super.init(frame: .zero)
        configure()
        setupUI()
    }
    
    func configure() {
        var config = UIButton.Configuration.filled()
        config.cornerStyle = .capsule
        config.baseBackgroundColor = .appBlue
        config.baseForegroundColor = .white
        config.titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer { incoming in
            var outgoing = incoming
            outgoing.font = UIFont.systemFont(ofSize: 11)
            return outgoing
        }
        configuration = config
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
