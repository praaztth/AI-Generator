//
//  ExploreStylesViewController.swift
//  AI-Generator
//
//  Created by катенька on 25.06.2025.
//

import Foundation
import UIKit
import RxSwift
import RxCocoa
import RxDataSources

class ExploreStylesViewController: UIViewController, ViewControllerConfigurable {
    let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: 170, height: 236)
        layout.minimumLineSpacing = 10
        layout.minimumInteritemSpacing = 10
        layout.scrollDirection = .vertical
        
        let view = UICollectionView(frame: .zero, collectionViewLayout: layout)
        view.register(ExploreTemplatesCollectionCell.self, forCellWithReuseIdentifier: ExploreTemplatesCollectionCell.reuseIdentifier)
        view.backgroundColor = .clear
        
        return view
    }()
    
    private let viewModel: ExploreStylesViewModelToView
    private let disposeBag = DisposeBag()
    
    init(viewModel: ExploreStylesViewModelToView) {
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
        configureNavBar()
        bindViewModel()
        
        viewModel.output.loadTrigger.accept(())
    }
    
    func setupUI() {
        view.backgroundColor = .black
        view.addSubview(collectionView)
    }
    
    func setupConstraints() {
        collectionView.snp.makeConstraints { make in
            make.top.bottom.left.right.equalTo(view.safeAreaLayoutGuide)
        }
    }
    
    func bindViewModel() {
        let dataSource = configureDataSource()
        
        viewModel.input.sectionedStylesDriver
            .drive(collectionView.rx.items(dataSource: dataSource))
            .disposed(by: disposeBag)
        
        collectionView.rx
            .modelSelected(Style.self)
            .bind(to: viewModel.output.didSelectStyle)
            .disposed(by: disposeBag)
    }
    
    func configureNavBar() {
        navigationController?.configureNavigationBar()
        
        navigationItem.title = "Styles"
        let imageBarButton = UIImage(systemName: "sparkles")
        let barButton = BarButton(title: "PRO", backgroundColor: .appBlue, image: imageBarButton)
        barButton.addTarget(self, action: #selector(openPaywallButtonTapped), for: .touchUpInside)
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: barButton)
    }
    
    @objc func openPaywallButtonTapped() {
        viewModel.output.didTapOpenPaywall.accept(())
    }
    
    func configureDataSource() -> RxCollectionViewSectionedReloadDataSource<SectionOfStyles> {
        return RxCollectionViewSectionedReloadDataSource<SectionOfStyles> { dataSource, collectionView, indexPath, item in
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ExploreTemplatesCollectionCell.reuseIdentifier, for: indexPath) as? ExploreTemplatesCollectionCell,
                  let url = URL(string: item.preview_small) else {
                return UICollectionViewCell(frame: .zero)
            }
            
            cell.configure(name: item.name, url: url)
            return cell
        }
    }
}
