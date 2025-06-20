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

protocol ExploreTemplatesViewControllerOutput {
    var sectionsDriver: Driver<[SectionOfTemplates]> { get }
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
        view = customView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureNavBar()
        bindViewModel()
    }
    
    func bindViewModel() {
        let dataSource = RxCollectionViewSectionedReloadDataSource<SectionOfTemplates> { dataSource, collectionView, indexPath, item in
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ExploreTemplatesCollectionCell.reuseIdentifier, for: indexPath) as? ExploreTemplatesCollectionCell else {
                return UICollectionViewCell(frame: .zero)
            }
            
            switch item {
            case .template(let templateItem):
                cell.configure(name: templateItem.name)
            case .style(let styleItem):
                cell.configure(name: styleItem.name)
            }
            
            return cell
        } configureSupplementaryView: { dataSource, collectionView, kind, indexPath in
            guard let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: TemplatesHeaderView.reuseIdentifier, for: indexPath) as? TemplatesHeaderView else { return UICollectionReusableView(frame: .zero) }
            header.configure(title: dataSource.sectionModels[indexPath.section].header)
            return header
        }
        
        viewModel.sectionsDriver
            .drive(customView.collectionView.rx.items(dataSource: dataSource))
            .disposed(by: disposeBag)
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
