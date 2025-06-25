//
//  UIButton+Styling.swift
//  AI-Generator
//
//  Created by катенька on 24.06.2025.
//

import UIKit

extension UIButton {
    public static func createInputImageButton(emptyIcon: UIImage?, enabledStateText: String, disabledStateText: String? = nil) -> UIButton {
        var config = UIButton.Configuration.bordered()
        config.image = emptyIcon
        config.imagePlacement = .all
        config.baseBackgroundColor = .appDark
        config.baseForegroundColor = .appPaleGrey30
        
        let button = UIButton(configuration: config)
        button.setTitle(enabledStateText, for: .normal)
        button.setTitle(disabledStateText, for: .disabled)
        button.contentMode = .scaleAspectFill
        button.layer.cornerRadius = 32
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor.appPaleGrey30.cgColor
        button.layer.masksToBounds = true
        
        return button
    }
}

extension UIButton {
    func setSelectedInputImage(_ image: UIImage?) {
        if let image = image {
            self.titleLabel?.isHidden = true
//            let imageSize = self.bounds.size
//            self.setImage(image.resize(targetSize: imageSize), for: .normal)
            self.setImage(image, for: .normal)
            self.layer.borderWidth = 0
        }
    }
    
    func removeInputImage(emptyIcon: UIImage) {
        self.titleLabel?.isHidden = false
        self.setImage(emptyIcon, for: .normal)
        self.layer.borderWidth = 1
    }
}
