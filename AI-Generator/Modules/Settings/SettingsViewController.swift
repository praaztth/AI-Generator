//
//  SettingsViewController.swift
//  AI-Generator
//
//  Created by катенька on 25.06.2025.
//

import UIKit
import RxSwift
import RxCocoa
import SnapKit

class SettingsViewController: UIViewController, ViewControllerConfigurable {
    private let viewModel: SettingsViewModelToView
    private let disposeBag = DisposeBag()
    
    private let tableView: UITableView = {
        let tableView = UITableView()
        tableView.backgroundColor = .clear
        return tableView
    }()
    
    init(viewModel: SettingsViewModelToView) {
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
        configureNavBar()
    }
    
    func setupUI() {
        view.backgroundColor = .black
        view.addSubview(tableView)
        
        tableView.register(SettingsTableViewCell.self, forCellReuseIdentifier: SettingsTableViewCell.reuseIdentifier)
    }
    
    func setupConstraints() {
        tableView.snp.makeConstraints { make in
            make.left.right.top.bottom.equalTo(view.safeAreaLayoutGuide)
        }
    }
    
    func bindViewModel() {
        viewModel.input.itemsToDisplay
            .bind(to: tableView.rx.items(cellIdentifier: SettingsTableViewCell.reuseIdentifier, cellType: SettingsTableViewCell.self)) { index, item, cell in
                cell.configure(title: item)
            }
            .disposed(by: disposeBag)
        
        tableView.rx.itemSelected
            .subscribe(onNext: { index in
                self.tableView.deselectRow(at: index, animated: true)
            })
            .disposed(by: disposeBag)
        
        tableView.rx.modelSelected(String.self)
            .subscribe(onNext: { item in
                self.viewModel.output.didTapItem.accept(item)
            })
            .disposed(by: disposeBag)
    }
    
    func configureNavBar() {
        navigationController?.configureNavigationBar()
        navigationItem.title = "Settings"
        let imageBarButton = UIImage(systemName: "sparkles")
        let barButton = BarButton(title: "PRO", backgroundColor: .appBlue, image: imageBarButton)
        barButton.addTarget(self, action: #selector(openPaywallButtonTapped), for: .touchUpInside)
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: barButton)
    }
    
    @objc func openPaywallButtonTapped() {
        viewModel.output.didTapOpenPaywall.accept(())
    }
}
