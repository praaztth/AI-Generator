//
//  PromptView.swift
//  AI-Generator
//
//  Created by катенька on 24.06.2025.
//

import UIKit
import SwiftHelper
import RxSwift
import RxCocoa

class PromptView: UIView {
    let titleLabel = SwiftHelper.uiHelper.customLabel(text: "Write a Promt", font: .systemFont(ofSize: 18))
    
    let textView: UITextView = {
        let view = UITextView()
        view.backgroundColor = .clear
        view.font = .systemFont(ofSize: 14)
        view.textColor = .appPaleGrey30
        view.text = "Type here a detailed description of what you want to see in your video"
        return view
    }()
    
    init() {
        super.init(frame: .zero)
        
        layer.cornerRadius = 32
        backgroundColor = .appDark
        
        addSubview(titleLabel)
        addSubview(textView)
        
        titleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(20)
            make.leading.equalToSuperview().offset(18)
        }
        
        textView.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(14)
            make.bottom.equalToSuperview().offset(-14)
            make.left.equalToSuperview().offset(18)
            make.right.equalToSuperview().offset(-18)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setTextViewDelegate(delegate: UITextViewDelegate) {
        textView.delegate = delegate
    }
}
