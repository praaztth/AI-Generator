//
//  ExploreTemplatesCollectionCell.swift
//  AI-Generator
//
//  Created by катенька on 20.06.2025.
//

import UIKit
import SwiftHelper
import SnapKit
import GSPlayer

class ExploreTemplatesCollectionCell: UICollectionViewCell {
    static let reuseIdentifier = "ExploreTemplatesCollectionCell"
    
    let label = SwiftHelper.uiHelper.customLabel(text: "", font: .systemFont(ofSize: 16))
    
    let playerView: VideoPlayerView = {
        let view = VideoPlayerView()
        view.contentMode = .scaleAspectFill
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupUI()
        setupConstraints()
    }
    
    func configure(name: String, url: URL) {
        label.text = name
        playerView.play(for: url)
        playerView.isMuted = true
    }
    
    func setupUI() {
        layer.cornerRadius = 12
        clipsToBounds = true
        addSubview(playerView)
        addSubview(label)
    }
    
    func setupConstraints() {
        playerView.snp.makeConstraints { make in
            make.top.bottom.left.right.equalToSuperview()
        }
        
        label.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(10)
            make.bottom.equalToSuperview().inset(12)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
