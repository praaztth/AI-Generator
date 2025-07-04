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
import PhotosUI

class UsePromptViewController: UIViewController, ViewControllerConfigurable {
    private let viewModel: UsePromptViewModelToView
    private let disposeBag = DisposeBag()
    
    private let promtView = PromptView()
    private let inputFieldButton = UIButton.createInputImageButton(emptyIcon: UIImage(systemName: "photo.on.rectangle.angled"), enabledStateText: "Tap here to add a photo if you'd like to supplement the generation", disabledStateText: "Unlock this feature with a PRO subscription and get access to all premium benefits")
    private let createButton = SwiftHelper.uiHelper.customAnimateButton(bgColor: .appDark, bgImage: nil, title: "Create", titleColor: .white, fontTitleColor: .systemFont(ofSize: 16), cornerRadius: 32, borderWidth: nil, borderColor: nil)
    
    init(viewModel: UsePromptViewModelToView) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        setupConstraints()
        bindViewModel()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.viewModel.output.loadData.accept(())
    }
    
    func setupUI() {
        view.backgroundColor = .black
        configureNavBar()
        
        view.addSubview(promtView)
        view.addSubview(inputFieldButton)
        view.addSubview(createButton)
        
        inputFieldButton.isEnabled = false
        promtView.setTextViewDelegate(delegate: self)
        createButton.isEnabled = false
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tapGesture.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGesture)
    }
    
    func setupConstraints() {
        promtView.snp.makeConstraints { make in
            make.top.leading.trailing.equalTo(view.safeAreaLayoutGuide)
            make.height.equalTo(171)
        }
        
        inputFieldButton.snp.makeConstraints { make in
            make.top.equalTo(promtView.snp.bottom).offset(97)
            make.left.right.equalTo(view.safeAreaLayoutGuide)
            make.bottom.equalTo(createButton.snp.top).offset(-24)
        }
        
        createButton.snp.makeConstraints { make in
            make.bottom.leading.trailing.equalTo(view.safeAreaLayoutGuide).inset(28)
            make.height.equalTo(60)
        }
    }
    
    func bindViewModel() {
        createButton.rx.tap
            .bind(to: viewModel.output.didTapCreate)
            .disposed(by: disposeBag)
        
        inputFieldButton.rx.tap
            .bind {
                self.displayImagePicker()
            }
            .disposed(by: disposeBag)
        
        viewModel.input.clearInputDataDriver
            .drive(onNext: { _ in
                self.promtView.textView.text = ""
                self.textViewDidEndEditing(self.promtView.textView)
                self.inputFieldButton.removeInputImage(emptyIcon: UIImage(systemName: "photo.on.rectangle.angled")!)
            })
            .disposed(by: disposeBag)
        
        viewModel.input.proAccessAvailableDriver
            .drive(onNext: { [weak self] isAvailable in
                self?.setUIEnabled(isAvailable)
            })
            .disposed(by: disposeBag)
    }
    
    func setUIEnabled(_ isEnabled: Bool) {
        inputFieldButton.isEnabled = isEnabled
        
    }
    
    func displayImagePicker() {
        var configuration = PHPickerConfiguration(photoLibrary: .shared())
        let filter = PHPickerFilter.images
        configuration.filter = filter
        configuration.preferredAssetRepresentationMode = .compatible
        configuration.selectionLimit = 1
        
        let picker = PHPickerViewController(configuration: configuration)
        picker.delegate = self
        present(picker, animated: true)
    }
    
    func configureNavBar() {
        navigationController?.configureNavigationBar()
        
        navigationItem.title = "Generation"
        let imageBarButton = UIImage(systemName: "sparkles")
        let barButton = BarButton(title: "PRO", backgroundColor: .appBlue, image: imageBarButton)
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

extension UsePromptViewController: PHPickerViewControllerDelegate {
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        picker.dismiss(animated: true)
        
        guard let result = results.first else { return }
        
        GalleryPickerHelper.handlePickedResults(ofType: UIImage.self, typeIdentifiers: [UTType.image.identifier], result: result)
            .observe(on: MainScheduler.instance)
            .subscribe { [weak self] image, url in
                self?.viewModel.output.setImageData(image: image)
                let imageName = url.lastPathComponent
                self?.viewModel.output.setImageName(name: imageName)
                DispatchQueue.main.async {
                    self?.inputFieldButton.setSelectedInputImage(image)
                }
                
            } onFailure: { error in
                print(error)
            }
            .disposed(by: disposeBag)
    }
}
