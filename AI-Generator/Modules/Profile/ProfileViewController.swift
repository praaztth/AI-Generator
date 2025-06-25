//
//  ProfileViewController.swift
//  AI-Generator
//
//  Created by катенька on 25.06.2025.
//

import Foundation
import UIKit
import RxSwift
import RxCocoa
import RxDataSources

class ProfileViewController: UIViewController, ViewControllerConfigurable {
    let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: 170, height: 236)
        layout.minimumLineSpacing = 10
        layout.minimumInteritemSpacing = 10
        layout.scrollDirection = .vertical
        
        let view = UICollectionView(frame: .zero, collectionViewLayout: layout)
        view.register(GeneratedVideosCollectionCell.self, forCellWithReuseIdentifier: GeneratedVideosCollectionCell.reuseIdentifier)
        view.backgroundColor = .clear
        
        return view
    }()
    
    private let viewModel: ProfileViewModelToView
    private let disposeBag = DisposeBag()
    
    init(viewModel: ProfileViewModelToView) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .black
        
        setupUI()
        setupConstraints()
        bindViewModel()
        
        viewModel.output.loadTrigger.accept(())
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupUI() {
        view.backgroundColor = .black
        configureNavBar()
        
        view.addSubview(collectionView)
    }
    
    func setupConstraints() {
        collectionView.snp.makeConstraints { make in
            make.top.bottom.left.right.equalTo(view.safeAreaLayoutGuide)
        }
    }
    
    func bindViewModel() {
        let dataSource = configureDataSource()
        
        viewModel.input.sectionedVideosDriver
            .drive(collectionView.rx.items(dataSource: dataSource))
            .disposed(by: disposeBag)
    }
    
    func configureNavBar() {
        navigationController?.configureNavigationBar()
        
        navigationItem.title = "Profile"
        let barButton = BarButton(title: "Settings", backgroundColor: .appPaleGrey30, image: nil)
        barButton.addTarget(self, action: #selector(openSettingsTapped), for: .touchUpInside)
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: barButton)
    }
    
    func configureDataSource() -> RxCollectionViewSectionedReloadDataSource<SectionOfVideos> {
        return RxCollectionViewSectionedReloadDataSource<SectionOfVideos> { dataSource, collectionView, indexPath, item in
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: GeneratedVideosCollectionCell.reuseIdentifier, for: indexPath) as? GeneratedVideosCollectionCell else {
                return UICollectionViewCell(frame: .zero)
            }
            
            cell.configure(image: item.previewImage)
            return cell
            
        }
    }
    
    @objc func openSettingsTapped() {
        
    }
}
