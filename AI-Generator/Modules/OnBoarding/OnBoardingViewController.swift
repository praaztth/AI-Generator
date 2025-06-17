//
//  OnBoardingViewController.swift
//  AI-Generator
//
//  Created by катенька on 17.06.2025.
//

import UIKit
import SnapKit

class OnBoardingViewController: UIViewController {
    var viewModel: OnBoardingViewModel?
    
    let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 34, weight: .bold)
        label.textColor = .white
        label.textAlignment = .center
        return label
    }()
    
    let descriptionLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16)
        label.textColor = .white
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()
    
    let backgroundImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    
    let nextButton: UIButton = {
        var config = UIButton.Configuration.filled()
        config.cornerStyle = .capsule
        config.baseBackgroundColor = .appBlue
        config.baseForegroundColor = .white
        let button = UIButton(configuration: config)
        return button
    }()
    
    let gradientView = GradientView()
    
    override func viewDidLoad() {
        setupUI()
    }
    
    func configure(page: OnBoardingPageModel) {
        titleLabel.text = page.title
        descriptionLabel.text = page.description
        backgroundImageView.image = UIImage(named: page.imageName)
        nextButton.setTitle("Next", for: .normal)
    }
    
    func setupUI() {
        view.backgroundColor = .black
        view.addSubview(backgroundImageView)
        view.addSubview(gradientView)
        view.addSubview(titleLabel)
        view.addSubview(descriptionLabel)
        view.addSubview(nextButton)
        
        setupConstraints()
    }
    
    func setupConstraints() {
        nextButton.snp.makeConstraints { make in
            make.bottom.equalTo(view.safeAreaLayoutGuide).offset(-40)
            make.leading.equalTo(view.safeAreaLayoutGuide).offset(16)
            make.trailing.equalTo(view.safeAreaLayoutGuide).offset(-16)
            make.height.equalTo(62)
        }
        
        descriptionLabel.snp.makeConstraints { make in
            make.bottom.equalTo(nextButton.snp.top).offset(-40)
            make.leading.equalTo(view).offset(40)
            make.trailing.equalTo(view).offset(-40)
        }
        
        titleLabel.snp.makeConstraints { make in
            make.bottom.equalTo(descriptionLabel.snp.top).offset(-40)
            make.centerX.equalTo(view)
        }
        
        backgroundImageView.snp.makeConstraints { make in
            make.top.equalTo(view)
            make.left.equalTo(view)
            make.right.equalTo(view)
            make.bottom.equalTo(titleLabel)
        }
        
        gradientView.snp.makeConstraints { make in
            make.height.equalTo(141)
            make.bottom.equalTo(titleLabel)
            make.left.equalTo(backgroundImageView)
            make.right.equalTo(backgroundImageView)
        }
    }
}
