//
//  SettingsCollectionCell.swift
//  AI-Generator
//
//  Created by катенька on 25.06.2025.
//

import UIKit

class SettingsTableViewCell: UITableViewCell {
    static let reuseIdentifier = "SettingsTableViewCell"
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        var config = self.defaultContentConfiguration()
        config.textProperties.color = .white
        config.textProperties.font = .systemFont(ofSize: 16)
        self.contentConfiguration = config
        self.backgroundColor = .clear
        self.accessoryType = .disclosureIndicator
        
        let selectedView = UIView()
        selectedView.backgroundColor = UIColor.white.withAlphaComponent(0.1)
        self.selectedBackgroundView = selectedView
    }
    
    func configure(title: String) {
        guard var config = contentConfiguration as? UIListContentConfiguration else { return }
        config.text = title
        contentConfiguration = config
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
