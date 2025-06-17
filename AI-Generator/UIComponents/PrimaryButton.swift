//
//  PrimaryButton.swift
//  AI-Generator
//
//  Created by катенька on 17.06.2025.
//

import UIKit

class PrimaryButton: UIButton {
    init(color: UIColor) {
        super.init(frame: .zero)
        var config = UIButton.Configuration.filled()
        config.cornerStyle = .capsule
        config.baseBackgroundColor = color
        config.baseForegroundColor = .white
        configuration = config
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
