//
//  ExploreTemplatesViewController.swift
//  AI-Generator
//
//  Created by катенька on 18.06.2025.
//

import UIKit
import RxSwift
import RxCocoa
import RxDataSources
import SwiftHelper
import ApphudSDK

protocol ExploreTemplatesViewControllerOutput {
    var sectionsDriver: Driver<[SectionOfTemplates]> { get }
    func didTapTemplate(at index: Int)
    func didTapOpenPaywall()
}

class ExploreTemplatesViewController: UIViewController {
    private let customView = ExploreTemplatesView()
    private let viewModel: ExploreTemplatesViewControllerOutput
    private let disposeBag = DisposeBag()
    
    init(viewModel: ExploreTemplatesViewControllerOutput) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        super.loadView()
        self.view = customView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureNavBar()
        bindViewModel()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        Apphud.restorePurchases { _, _, _ in
            self.updateProButton()
        }
    }
    
    func bindViewModel() {
        let dataSource = configureDataSource()
        
        viewModel.sectionsDriver
            .drive(customView.collectionView.rx.items(dataSource: dataSource))
            .disposed(by: disposeBag)
        
        customView.collectionView.rx
            .modelSelected(Template.self)
            .subscribe(onNext: { item in
                self.viewModel.didTapTemplate(at: item.template_id)
            })
            .disposed(by: disposeBag)
    }
    
    func updateProButton() {
        if !SwiftHelper.apphudHelper.isProUser() {
            let imageBarButton = UIImage(systemName: "sparkles")
            let barButton = BarButton(title: "PRO", backgroundColor: .appBlue, image: imageBarButton)
            barButton.addTarget(self, action: #selector(openPaywallButtonTapped), for: .touchUpInside)
            navigationItem.rightBarButtonItem = UIBarButtonItem(customView: barButton)
        } else {
            navigationItem.rightBarButtonItem = nil
        }
    }
    
    func configureNavBar() {
        navigationController?.configureNavigationBar()
        navigationItem.title = "Templates"
    }
    
    @objc func openPaywallButtonTapped() {
        viewModel.didTapOpenPaywall()
    }
    
    func configureDataSource() -> RxCollectionViewSectionedReloadDataSource<SectionOfTemplates> {
        return RxCollectionViewSectionedReloadDataSource<SectionOfTemplates> { dataSource, collectionView, indexPath, item in
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ExploreTemplatesCollectionCell.reuseIdentifier, for: indexPath) as? ExploreTemplatesCollectionCell else {
                return UICollectionViewCell(frame: .zero)
            }
            
            cell.configure(name: item.name)
            return cell
            
        } configureSupplementaryView: { dataSource, collectionView, kind, indexPath in
            guard let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: TemplatesHeaderView.reuseIdentifier, for: indexPath) as? TemplatesHeaderView else { return UICollectionReusableView(frame: .zero) }
            
            header.configure(title: dataSource.sectionModels[indexPath.section].header)
            return header
        }
    }
}
