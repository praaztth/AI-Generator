//
//  VideoGenerationViewController.swift
//  AI-Generator
//
//  Created by катенька on 24.06.2025.
//

import Foundation
import UIKit

class VideoGenerationViewController: UIViewController, ViewControllerConfigurable {
    let activityView: UIActivityIndicatorView = {
        let activityView = UIActivityIndicatorView(style: .large)
        activityView.color = .white
        return activityView
    }()
    
    private let viewModel: VideoGenerationViewModelToView
    
    init(viewModel: VideoGenerationViewModelToView) {
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
        
        view.addSubview(activityView)
        activityView.startAnimating()
    }
    
    func setupConstraints() {
        activityView.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
    }
    
    func bindViewModel() {
        
    }
    
    deinit {
        viewModel.input.didCloseView.accept(())
    }
}
