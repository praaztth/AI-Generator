//
//  PaywallViewController.swift
//  AI-Generator
//
//  Created by катенька on 18.06.2025.
//

import UIKit
import RxSwift

protocol PaywallViewControllerOutput {
    func didSelectedUpperButton()
    func didSelectedLowerButton()
    func didTappedSubscribeButton()
}

class PaywallViewController: UIViewController {
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
    
    let upperButton = SelectableOptionButton(leftTitle: "Weekly", leftSubtitle: "Just $ 9.99 per month", rightTitle: "$9.99", rightSubtitle: "right now")
    let lowerButton = SelectableOptionButton(leftTitle: "Yearly", leftSubtitle: "Just $ 99.99 per year", rightTitle: "$8.33", rightSubtitle: "per month")
    let subscribeButton = PrimaryButton(color: .appBlue)
    let gradientView = GradientView()
    
    let viewModel: PaywallViewControllerOutput
    
    init(viewModel: PaywallViewControllerOutput) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        setupUI()
        setupConstraints()
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
        
        upperButton.isSelected = true
        upperButton.addTarget(self, action: #selector(didSelectedUpperButton(_:)), for: .valueChanged)
        lowerButton.addTarget(self, action: #selector(didSelectedLowerButton(_:)), for: .valueChanged)
        view.addSubview(upperButton)
        view.addSubview(lowerButton)
        
        subscribeButton.setTitle("Subscribe", for: .normal)
        subscribeButton.addTarget(self, action: #selector(didTappedSubscribeButton), for: .touchUpInside)
        view.addSubview(subscribeButton)
    }
    
    func bindViewModel() {
        
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
            make.bottom.equalTo(upperButton.snp.top).offset(-24)
            make.height.equalTo(118)
        }
        
        upperButton.snp.makeConstraints { make in
            make.leading.equalTo(view.safeAreaLayoutGuide).offset(16)
            make.trailing.equalTo(view.safeAreaLayoutGuide).offset(-16)
            make.bottom.equalTo(lowerButton.snp.top).offset(-10)
            make.height.equalTo(66)
        }
        
        lowerButton.snp.makeConstraints { make in
            make.leading.equalTo(view.safeAreaLayoutGuide).offset(16)
            make.trailing.equalTo(view.safeAreaLayoutGuide).offset(-16)
            make.bottom.equalTo(subscribeButton.snp.top).offset(-20)
            make.height.equalTo(66)
        }
        
        subscribeButton.snp.makeConstraints { make in
            make.leading.equalTo(view.safeAreaLayoutGuide).offset(16)
            make.trailing.equalTo(view.safeAreaLayoutGuide).offset(-16)
            make.bottom.equalTo(view.safeAreaLayoutGuide).offset(-32)
            make.height.equalTo(62)
        }
        
        gradientView.snp.makeConstraints { make in
            make.height.equalTo(141)
            make.bottom.equalTo(titleLabel)
            make.left.equalTo(backgroundImageView)
            make.right.equalTo(backgroundImageView)
        }
    }
    
    @objc func didSelectedUpperButton(_ sender: UIButton) {
        lowerButton.isSelected = false
        viewModel.didSelectedUpperButton()
    }
    
    @objc func didSelectedLowerButton(_ sender: UIButton) {
        upperButton.isSelected = false
        viewModel.didSelectedLowerButton()
    }
    
    @objc func didTappedSubscribeButton() {
        viewModel.didTappedSubscribeButton()
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
