//
//  UsePromptViewController.swift
//  AI-Generator
//
//  Created by катенька on 24.06.2025.
//

import Foundation
import UIKit
import RxSwift
import RxCocoa
import SwiftHelper

class UsePromptViewController: UIViewController, ViewControllerConfigurable {
    private let viewModel: UsePromptViewModelToView
    private let disposeBag = DisposeBag()
    
    private let promtView = PromptView()
    private let createButton = SwiftHelper.uiHelper.customAnimateButton(bgColor: .appDark, bgImage: nil, title: "Create", titleColor: .white, fontTitleColor: .systemFont(ofSize: 16), cornerRadius: 32, borderWidth: nil, borderColor: nil)
    
    init(viewModel: UsePromptViewModelToView) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        setupConstraints()
        bindViewModel()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupUI() {
        view.backgroundColor = .black
        configureNavBar()
        
        view.addSubview(promtView)
        view.addSubview(createButton)
        
        promtView.setTextViewDelegate(delegate: self)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tapGesture.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGesture)
    }
    
    func setupConstraints() {
        promtView.snp.makeConstraints { make in
            make.top.leading.trailing.equalTo(view.safeAreaLayoutGuide)
            make.height.equalTo(171)
        }
        
        createButton.snp.makeConstraints { make in
            make.bottom.leading.trailing.equalTo(view.safeAreaLayoutGuide)
            make.height.equalTo(60)
        }
    }
    
    func bindViewModel() {
        createButton.rx.tap
            .subscribe(onNext: {
                self.viewModel.output.didTapCreate.accept(())
            })
            .disposed(by: disposeBag)
    }
    
    func configureNavBar() {
        navigationController?.configureNavigationBar()
        
        navigationItem.title = "Generation"
        let barButton = OpenPaywallBarButton()
        barButton.addTarget(self, action: #selector(openPaywallButtonTapped), for: .touchUpInside)
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: barButton)
    }
    
    @objc func openPaywallButtonTapped() {
        viewModel.output.didTappedOpenPaywall.accept(())
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
}

extension UsePromptViewController: UITextViewDelegate {
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == .appPaleGrey30 {
            textView.text = ""
            textView.textColor = .white
            createButton.isEnabled = true
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text == "" {
            textView.text = "Type here a detailed description of what you want to see in your video"
            textView.textColor = .appPaleGrey30
            createButton.isEnabled = false
            viewModel.output.promptToGenerate.accept(nil)
        } else {
            createButton.isEnabled = true
            viewModel.output.promptToGenerate.accept(textView.text)
        }
    }
}
