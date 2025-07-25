//
//  UseEffectView.swift
//  AI-Generator
//
//  Created by катенька on 20.06.2025.
//

import UIKit
import RxSwift
import RxCocoa
import SwiftHelper
import GSPlayer

class UseEffectView: UIView {
    let playerView = VideoPlayerView()
    let titleLabel = SwiftHelper.uiHelper.customLabel(text: "", font: .systemFont(ofSize: 22, weight: .bold))
    let createButton = SwiftHelper.uiHelper.customAnimateButton(bgColor: .appDark, bgImage: nil, title: "Create", titleColor: .white, fontTitleColor: .systemFont(ofSize: 16), cornerRadius: 32)
    let disposeBag = DisposeBag()
    
    let activityIndicator: UIActivityIndicatorView = {
        let activityIndicator = UIActivityIndicatorView(style: .large)
        activityIndicator.color = .gray
        activityIndicator.hidesWhenStopped = true
        return activityIndicator
    }()
    
    let errorImageView = SwiftHelper.uiHelper.customImageView(image: UIImage(systemName: "exclamationmark.circle") ?? UIImage(), mode: UIView.ContentMode.center)
    let errorContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = .appDark
        view.layer.cornerRadius = 20
        view.layer.masksToBounds = true
        return view
    }()
    
    let inputFieldButton = UIButton.createInputImageButton(emptyIcon: UIImage(systemName: "photo.on.rectangle.angled"), enabledStateText: "Tap here to add a photo if you'd like to supplement the generation", disabledStateText: "Unlock this feature with a PRO subscription and get access to all premium benefits")
    
    init() {
        super.init(frame: .zero)
        setupUI()
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupUI() {
        backgroundColor = .black
        playerView.contentMode = .scaleAspectFill
        playerView.playerLayer.cornerRadius = 20
        playerView.playerLayer.masksToBounds = true
        
        activityIndicator.hidesWhenStopped = true
        
        errorContainerView.addSubview(errorImageView)
        errorContainerView.isHidden = true
        
        inputFieldButton.isEnabled = false
        createButton.isEnabled = false
        
        addSubview(playerView)
        addSubview(titleLabel)
        addSubview(inputFieldButton)
        addSubview(createButton)
        addSubview(activityIndicator)
        addSubview(errorContainerView)
    }
    
    func setupConstraints() {
        createButton.snp.makeConstraints { make in
            make.left.right.equalTo(safeAreaLayoutGuide)
            make.bottom.equalTo(safeAreaLayoutGuide).offset(-20)
            make.height.equalTo(64)
        }
        
        inputFieldButton.snp.makeConstraints { make in
            make.left.right.equalTo(safeAreaLayoutGuide)
            make.bottom.equalTo(createButton.snp.top).offset(-32)
            make.height.equalTo(188)
        }
        
        titleLabel.snp.makeConstraints { make in
            make.left.right.equalTo(safeAreaLayoutGuide).offset(8)
            make.bottom.equalTo(inputFieldButton.snp.top).offset(-28)
        }
        
        playerView.snp.makeConstraints { make in
            make.top.left.right.equalToSuperview()
            make.bottom.equalTo(titleLabel.snp.top).offset(-21)
        }
        
        activityIndicator.snp.makeConstraints { make in
            make.center.equalTo(playerView)
        }
        
        errorContainerView.snp.makeConstraints { make in
            make.top.left.right.equalToSuperview()
            make.bottom.equalTo(titleLabel.snp.top).offset(-21)
        }
    }
    
    func configure(withObject object: UseEffectModel) {
        titleLabel.text = object.title
        
        if let url = object.videoURL {
            playerView.play(for: url)
            playerView.isMuted = true
        } else {
            showError()
        }
    }
    
    func setSelectedImage(image: UIImage) {
        inputFieldButton.setSelectedInputImage(image)
    }
    
    func setVideoStateDidChagedCallback(callback: @escaping (VideoPlayerView.State) -> Void) {
        playerView.stateDidChanged = callback
    }
    
    func bindInputButton(to relay: PublishRelay<Void>) {
        inputFieldButton.rx.tap.bind(to: relay).disposed(by: disposeBag)
    }
    
    func bindCreateButton(to relay: PublishRelay<Void>) {
        createButton.rx.tap.bind(to: relay).disposed(by: disposeBag)
    }
    
    func startActivityIndicator() {
        activityIndicator.startAnimating()
    }
    
    func stopActivityIndicator() {
        activityIndicator.stopAnimating()
    }
    
    func showError() {
        activityIndicator.stopAnimating()
        playerView.isHidden = true
        errorContainerView.isHidden = false
    }
    
    func setUIEnabled(_ isEnabled: Bool) {
        inputFieldButton.isEnabled = isEnabled
        createButton.isEnabled = isEnabled
    }
}


