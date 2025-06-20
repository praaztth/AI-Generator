//
//  TemplatesHeaderView.swift
//  AI-Generator
//
//  Created by катенька on 20.06.2025.
//

import UIKit
import SwiftHelper
import RxDataSources

class TemplatesHeaderView: UICollectionReusableView {
    static let reuseIdentifier = "TemplatesHeaderView"
    
    let titleLabel = SwiftHelper.uiHelper.customLabel(text: "", font: .systemFont(ofSize: 18))
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.top.bottom.leading.trailing.equalToSuperview()
        }
    }
    
    func configure(title: String) {
        titleLabel.text = title
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
