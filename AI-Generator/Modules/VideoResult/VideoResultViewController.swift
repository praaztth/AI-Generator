//
//  VideoResultViewController.swift
//  AI-Generator
//
//  Created by катенька on 23.06.2025.
//

import UIKit
import RxSwift
import GSPlayer
import SwiftHelper

class VideoResultViewController: UIViewController, ViewControllerConfigurable {
    private let viewModel: VideoResultViewModelToView
    private let disposeBag = DisposeBag()
    
    let playerView: VideoPlayerView = {
        let view = VideoPlayerView()
        view.contentMode = .scaleAspectFill
        view.playerLayer.cornerRadius = 16
        view.playerLayer.masksToBounds = true
        return view
    }()
    
    let button = SwiftHelper.uiHelper.customAnimateButton(bgColor: UIColor.appBlue, bgImage: nil, title: "Save to gallery", titleColor: UIColor.white, fontTitleColor: .systemFont(ofSize: 16), cornerRadius: 32, borderWidth: nil, borderColor: nil)
    
    init(viewModel: VideoResultViewModelToView) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        setupUI()
        setupConstraints()
        bindViewModel()
    }
    
    func setupUI() {
        view.backgroundColor = .black
        view.addSubview(playerView)
        view.addSubview(button)
    }
    
    func setupConstraints() {
        playerView.snp.makeConstraints { make in
            make.top.left.right.equalTo(view.safeAreaLayoutGuide)
            make.bottom.equalTo(button.snp.top).offset(-36)
        }
        
        button.snp.makeConstraints { make in
            make.bottom.leading.trailing.equalTo(view.safeAreaLayoutGuide)
            make.height.equalTo(62)
        }
    }
    
    func bindViewModel() {
        // Binding Input
        button.rx.tap.bind(to: viewModel.input.didSaveTapped)
            .disposed(by: disposeBag)
        
        // Bindong Output
        viewModel.output.videoURL
            .drive { [weak self] url in
                self?.playerView.play(for: url)
                self?.playerView.isMuted = true
            }
            .disposed(by: disposeBag)
    }
    
    deinit {
        viewModel.input.didCloseView.onNext(true)
    }
}
