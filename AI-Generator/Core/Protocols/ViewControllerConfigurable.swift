//
//  ViewControllerConfigurable.swift
//  AI-Generator
//
//  Created by катенька on 24.06.2025.
//

import Foundation
import UIKit

protocol ViewControllerConfigurable {
    func setupUI()
    func setupConstraints()
    func bindViewModel()
}
