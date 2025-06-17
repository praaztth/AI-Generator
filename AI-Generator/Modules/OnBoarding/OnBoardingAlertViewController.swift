//
//  OnBoardingAlertViewController.swift
//  AI-Generator
//
//  Created by катенька on 17.06.2025.
//

import RxSwift
import RxCocoa

class OnBoardingAlertViewController: OnBoardingViewController {
    let cancelButton = PrimaryButton(color: .appDarkGray)
    
    override func configure(title: String, description: String, imageName: String) {
        super.configure(title: title, description: description, imageName: imageName)
        nextButton.setTitle("Yes, I love it", for: .normal)
        cancelButton.setTitle("No, I don’t", for: .normal)
    }
    
    override func bindViewModel() {
        super.bindViewModel()
        
        guard let viewModel = viewModel as? OnBoardingAlertViewModel else { return }
        
        cancelButton.rx.tap.bind(to: viewModel.didTapCancel).disposed(by: disposeBag)
    }
    
    override func setupUI() {
        super.setupUI()
        
        view.addSubview(cancelButton)
    }
    
    override func setupConstraints() {
        super.setupConstraints()
        
        cancelButton.snp.makeConstraints { make in
            make.bottom.equalTo(view.safeAreaLayoutGuide).offset(-40)
            make.leading.equalTo(view.safeAreaLayoutGuide).offset(16)
            make.trailing.equalTo(view.safeAreaLayoutGuide).offset(-16)
            make.height.equalTo(62)
        }
        
        nextButton.snp.remakeConstraints { make in
            make.bottom.equalTo(cancelButton.snp.top).offset(-16)
            make.leading.equalTo(view.safeAreaLayoutGuide).offset(16)
            make.trailing.equalTo(view.safeAreaLayoutGuide).offset(-16)
            make.height.equalTo(62)
        }
    }
}
