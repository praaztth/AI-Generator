//
//  ExploreTemplatesViewController.swift
//  AI-Generator
//
//  Created by катенька on 18.06.2025.
//

import UIKit

protocol ExploreTemplatesViewControllerOutput {
    func didTapOpenPaywall()
}

class ExploreTemplatesViewController: UIViewController {
    let customView = UIView()
    let viewModel: ExploreTemplatesViewControllerOutput
    
    init(viewModel: ExploreTemplatesViewControllerOutput) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        super.loadView()
        view = customView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureNavBar()
    }
    
    func configureNavBar() {
        let navBarAppearance = UINavigationBarAppearance()
        navBarAppearance.configureWithOpaqueBackground()
        navBarAppearance.backgroundColor = .black
        navBarAppearance.titleTextAttributes = [.foregroundColor: UIColor.white]
        navBarAppearance.largeTitleTextAttributes = [.foregroundColor: UIColor.white]
        navigationController?.navigationBar.standardAppearance = navBarAppearance
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationController?.navigationBar.tintColor = .white
        
        navigationItem.title = "Templates"
        let barButton = OpenPaywallBarButton()
        barButton.addTarget(self, action: #selector(openPaywallButtonTapped), for: .touchUpInside)
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: barButton)
    }
    
    @objc func openPaywallButtonTapped() {
        viewModel.didTapOpenPaywall()
    }
}
