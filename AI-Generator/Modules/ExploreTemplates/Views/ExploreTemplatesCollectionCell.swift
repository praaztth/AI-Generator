//
//  ExploreTemplatesCollectionCell.swift
//  AI-Generator
//
//  Created by катенька on 20.06.2025.
//

import UIKit
import SwiftHelper
import SnapKit

class ExploreTemplatesCollectionCell: UICollectionViewCell {
    static let reuseIdentifier = "ExploreTemplatesCollectionCell"
    
    let label = SwiftHelper.uiHelper.customLabel(text: "", font: .systemFont(ofSize: 16))
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupUI()
        setupConstraints()
    }
    
    func configure(name: String) {
        label.text = name
    }
    
    func setupUI() {
        backgroundColor = .gray
        addSubview(label)
    }
    
    func setupConstraints() {
        label.snp.makeConstraints { make in
            make.leading.bottom.equalToSuperview()
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
