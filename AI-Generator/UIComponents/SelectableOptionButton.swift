//
//  SelectableOptionButton.swift
//  AI-Generator
//
//  Created by катенька on 18.06.2025.
//

import UIKit

class SelectableOptionButton: UIButton {
    override var isSelected: Bool {
        didSet {
            updateAppearance()
        }
    }
    
    var leftView: UIView!
    var rightView: UIView!
    
    let circleView = UIView()
    
    let outerCircle: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 12
        view.layer.borderWidth = 3
        view.layer.borderColor = UIColor.appBlue.cgColor
        return view
    }()
    
    let innerCircle: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 7
        view.backgroundColor = UIColor.appBlue
        return view
    }()
    
    init(leftTitle: String, leftSubtitle: String, rightTitle: String, rightSubtitle: String) {
        super.init(frame: .zero)
        setupUI(leftTitle: leftTitle, leftSubtitle: leftSubtitle, rightTitle: rightTitle, rightSubtitle: rightSubtitle)
        setupConstraints()
        updateAppearance()
        
        addTarget(self, action: #selector(toggleChanged), for: .touchUpInside)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupUI(leftTitle: String, leftSubtitle: String, rightTitle: String, rightSubtitle: String) {
        layer.cornerRadius = 16
        backgroundColor = UIColor.appBlack60
        layer.borderColor = UIColor.appBlue.cgColor
        
        leftView = getVerticalLabelsView(title: leftTitle, subtitle: leftSubtitle, textAligment: .left)
        rightView = getVerticalLabelsView(title: rightTitle, subtitle: rightSubtitle, textAligment: .right)
        
        circleView.isUserInteractionEnabled = false
        outerCircle.isUserInteractionEnabled = false
        innerCircle.isUserInteractionEnabled = false
        circleView.addSubview(outerCircle)
        circleView.addSubview(innerCircle)
        
        addSubview(leftView)
        addSubview(rightView)
        addSubview(circleView)
    }
    
    func setupConstraints() {
        leftView.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(20)
            make.centerY.equalToSuperview()
        }
        
        rightView.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.trailing.equalTo(circleView.snp.leading).offset(-24)
        }
        
        circleView.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.trailing.equalToSuperview().offset(-20)
        }
        
        outerCircle.snp.makeConstraints { make in
            make.top.bottom.leading.trailing.equalToSuperview()
            make.height.width.equalTo(24)
        }
        
        innerCircle.snp.makeConstraints { make in
            make.center.equalTo(outerCircle)
            make.height.width.equalTo(14)
        }
    }
    
    func updateAppearance() {
        if isSelected {
            outerCircle.layer.borderColor = UIColor.appBlue.cgColor
            innerCircle.backgroundColor = .appBlue
            layer.borderWidth = 1
        } else {
            outerCircle.layer.borderColor = UIColor.appGrey.cgColor
            innerCircle.backgroundColor = .clear
            layer.borderWidth = 0
        }
    }
    
    @objc func toggleChanged() {
        if !isSelected {
            isSelected.toggle()
            sendActions(for: .valueChanged)
        }
    }
    
    func getVerticalLabelsView(title: String, subtitle: String, textAligment: NSTextAlignment) -> UIView {
        let titleLabel = UILabel()
        titleLabel.font = .systemFont(ofSize: 18, weight: .bold)
        titleLabel.textColor = .white
        titleLabel.text = title
        titleLabel.textAlignment = textAligment
        
        let subtitleLabel = UILabel()
        subtitleLabel.font = .systemFont(ofSize: 12)
        subtitleLabel.textColor = .white
        subtitleLabel.text = subtitle
        subtitleLabel.textAlignment = textAligment
        
        let view = UIView()
        view.isUserInteractionEnabled = false
        view.addSubview(titleLabel)
        view.addSubview(subtitleLabel)
        
        titleLabel.snp.makeConstraints { make in
            make.left.top.right.equalToSuperview()
            make.bottom.equalTo(subtitleLabel.snp.top).offset(-2)
        }
        
        subtitleLabel.snp.makeConstraints { make in
            make.left.bottom.right.equalToSuperview()
        }
        
        return view
    }
}
