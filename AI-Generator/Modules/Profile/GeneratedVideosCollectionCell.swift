//
//  GeneratedVideosCollectionCell.swift
//  AI-Generator
//
//  Created by катенька on 25.06.2025.
//

import UIKit

class GeneratedVideosCollectionCell: UICollectionViewCell {
    static let reuseIdentifier = "GeneratedVideosCollectionCell"
    
    private let previewView: UIImageView = {
        let imageView = UIImageView()
        imageView.layer.cornerRadius = 6
        imageView.clipsToBounds = true
        return imageView
    }()
    
    private let playView: UIImageView = {
        let imageView = UIImageView(image: UIImage(systemName: "play.fill"))
        imageView.tintColor = .white
        imageView.alpha = 0.6
        imageView.backgroundColor = .black
        imageView.layer.cornerRadius = 47/2
        imageView.clipsToBounds = true
        return imageView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupUI()
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(image: UIImage) {
        previewView.image = image
        previewView.backgroundColor = .gray
    }
    
    func setupUI() {
        addSubview(previewView)
        addSubview(playView)
    }
    
    func setupConstraints() {
        previewView.snp.makeConstraints { make in
            make.top.bottom.left.right.equalToSuperview()
        }
        
        playView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.height.width.equalTo(47)
        }
    }
}
