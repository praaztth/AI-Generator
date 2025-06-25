//
//  PaywallViewController.swift
//  AI-Generator
//
//  Created by катенька on 18.06.2025.
//

import UIKit
import RxSwift
import SwiftHelper

class PaywallViewController: UIViewController, ViewControllerConfigurable {
    // TODO: добавить градиент в границу выбранной option button и в subscribe кнопку
    // TODO: добавить серые кнопки с макета под subscription кнопкой
    let backgroundImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        return imageView
    }()
    
    let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 29, weight: .bold)
        label.textColor = .white
        return label
    }()
    
    let descriptionViewStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 14
        stack.alignment = .leading
        return stack
    }()
    
    let optionButtonsStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 10
        stack.alignment = .fill
        return stack
    }()
    
    let restorePurchasesButton = SwiftHelper.uiHelper.customAnimateButton(bgColor: .clear, bgImage: nil, title: "Restore Purchases", titleColor: .appGrey, fontTitleColor: .systemFont(ofSize: 12), cornerRadius: nil, borderWidth: nil, borderColor: nil)
    
    let closeButton: UIButton = {
        var config = UIButton.Configuration.plain()
        config.baseForegroundColor = .white
        config.baseBackgroundColor = .clear
        config.image = UIImage(systemName: "xmark")
        let button = UIButton(configuration: config)
        return button
    }()
    
    let subscribeButton = PrimaryButton(color: .appBlue)
    let gradientView = GradientView()
    
    private let viewModel: PaywallViewModelToView
    private let disposeBag = DisposeBag()
    
    init(viewModel: PaywallViewModelToView) {
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
        
        viewModel.output.loadTrigger.accept(())
    }
    
    func setupUI() {
        view.backgroundColor = .black
        
        view.addSubview(backgroundImageView)
        view.addSubview(gradientView)
        view.addSubview(titleLabel)
        
        backgroundImageView.image = UIImage(named: "paywallBackground")
        titleLabel.text = "Try Pro version"
        
        [
            "Generate Photo/Video with promts",
            "Have fun with Video Templates",
            "Upload Photos, Videos for Generation",
            "Save and Share with friends"
        ].forEach { string in
            let view = getDescriptionView(text: string)
            descriptionViewStack.addArrangedSubview(view)
        }
        
        view.addSubview(descriptionViewStack)
        view.addSubview(optionButtonsStack)
        
        subscribeButton.setTitle("Subscribe", for: .normal)
        subscribeButton.addTarget(self, action: #selector(didTappedSubscribeButton), for: .touchUpInside)
        restorePurchasesButton.addTarget(self, action: #selector(didTappedRestorePurchasesButton), for: .touchUpInside)
        closeButton.addTarget(self, action: #selector(didTappedCloseButton), for: .touchUpInside)
        
        view.addSubview(subscribeButton)
        view.addSubview(restorePurchasesButton)
        view.addSubview(closeButton)
    }
    
    func setupConstraints() {
        backgroundImageView.snp.makeConstraints { make in
            make.top.left.right.equalTo(view)
            make.bottom.equalTo(titleLabel)
        }
        
        titleLabel.snp.makeConstraints { make in
            make.leading.equalTo(view.safeAreaLayoutGuide).offset(16)
            make.bottom.equalTo(descriptionViewStack.snp.top).offset(-20)
        }
        
        descriptionViewStack.snp.makeConstraints { make in
            make.leading.equalTo(view.safeAreaLayoutGuide).offset(16)
            make.trailing.equalTo(view.safeAreaLayoutGuide).offset(-16)
            make.bottom.equalTo(optionButtonsStack.snp.top).offset(-24)
            make.height.equalTo(118)
        }
        
        optionButtonsStack.snp.makeConstraints { make in
            make.leading.equalTo(view.safeAreaLayoutGuide).offset(16)
            make.trailing.equalTo(view.safeAreaLayoutGuide).offset(-16)
            make.bottom.equalTo(subscribeButton.snp.top).offset(-20)
        }
        
        subscribeButton.snp.makeConstraints { make in
            make.leading.equalTo(view.safeAreaLayoutGuide).offset(16)
            make.trailing.equalTo(view.safeAreaLayoutGuide).offset(-16)
            make.bottom.equalTo(restorePurchasesButton.snp.top)
            make.height.equalTo(62)
        }
        
        restorePurchasesButton.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.height.equalTo(40)
            make.bottom.equalTo(view.safeAreaLayoutGuide)
        }
        
        gradientView.snp.makeConstraints { make in
            make.height.equalTo(141)
            make.bottom.equalTo(titleLabel)
            make.left.equalTo(backgroundImageView)
            make.right.equalTo(backgroundImageView)
        }
        
        closeButton.snp.makeConstraints { make in
            make.height.width.equalTo(40)
            make.top.right.equalTo(view.safeAreaLayoutGuide)
        }
    }
    
    func bindViewModel() {
        viewModel.input.productsDriver
            .drive(onNext: { [weak self] products in
                self?.setProfuctsButtons(products: products)
            })
            .disposed(by: disposeBag)
    }
    
    func setProfuctsButtons(products: [PaywallProductModel]) {
        products.forEach { product in
            let button = SelectableOptionButton(leftTitle: product.name, leftSubtitle: product.description, rightTitle: product.price, rightSubtitle: product.paymentPeriod)
            button.addTarget(self, action: #selector(didSelectedOptionButton(_:)), for: .valueChanged)
            optionButtonsStack.addArrangedSubview(button)
            
            button.snp.makeConstraints { make in
                make.height.equalTo(66)
            }
        }
        
        guard let firstButton = optionButtonsStack.arrangedSubviews.first as? SelectableOptionButton else { return }
        firstButton.isSelected = true
    }
    
    @objc func didSelectedOptionButton(_ sender: UIButton) {
        guard let optionButton = sender as? SelectableOptionButton,
              let buttonIndex = optionButtonsStack.arrangedSubviews.firstIndex(where: { $0 == optionButton }) else { return }
        
        optionButtonsStack.arrangedSubviews.forEach { button in
            guard let button = button as? SelectableOptionButton else { return }
            if button == optionButton { return }
            button.isSelected = false
        }
        
        viewModel.output.didSelectSubscriptionPlan.accept(buttonIndex)
    }
    
    @objc func didTappedSubscribeButton() {
        viewModel.output.didTapSubscribe.accept(())
    }
    
    @objc func didTappedRestorePurchasesButton() {
        viewModel.output.didTapRestorePurchases.accept(())
    }
    
    @objc func didTappedCloseButton() {
        viewModel.output.didTapClose.accept(())
    }
    
    func getDescriptionView(text: String) -> UIView {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16)
        label.textColor = .white
        label.text = text
        
        let imageView = UIImageView(image: UIImage(systemName: "checkmark"))
        imageView.contentMode = .scaleAspectFit
        imageView.tintColor = .white
        
        let imageContainer = UIView()
        imageContainer.layer.cornerRadius = 9.5
        imageContainer.layer.borderColor = UIColor.appBlue.cgColor
        imageContainer.layer.borderWidth = 1
        imageContainer.addSubview(imageView)
        
        let view = UIView()
        view.addSubview(label)
        view.addSubview(imageContainer)
        
        label.snp.makeConstraints { make in
            make.centerY.equalTo(view)
            make.trailing.equalTo(view)
        }
        
        imageContainer.snp.makeConstraints { make in
            make.top.bottom.equalTo(view)
            make.leading.equalTo(view)
            make.trailing.equalTo(label.snp.leading).offset(-10)
            make.height.width.equalTo(19)
        }
        
        imageView.snp.makeConstraints { make in
            make.top.leading.bottom.trailing.equalToSuperview().inset(2)
        }
        
        return view
    }
}
