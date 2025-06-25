//
//  ExploreTemplatesView.swift
//  AI-Generator
//
//  Created by катенька on 20.06.2025.
//

import UIKit
import SnapKit

class ExploreTemplatesView: UIView {
    let collectionView: UICollectionView = {
        let view = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewLayout())
        view.register(ExploreTemplatesCollectionCell.self, forCellWithReuseIdentifier: ExploreTemplatesCollectionCell.reuseIdentifier)
        view.register(TemplatesHeaderView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: TemplatesHeaderView.reuseIdentifier)
        view.backgroundColor = .clear
        
        return view
    }()
    
    init() {
        super.init(frame: .zero)
        setupUI()
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupUI() {
        backgroundColor = .black
        
        collectionView.collectionViewLayout = getLayoutForCollectionView()
        addSubview(collectionView)
    }
    
    func setupConstraints() {
        collectionView.snp.makeConstraints { make in
            make.top.bottom.left.right.equalTo(safeAreaLayoutGuide)
        }
    }
    
    func getLayoutForCollectionView() -> UICollectionViewCompositionalLayout {
        return UICollectionViewCompositionalLayout { sectionIndex, _ in
            let itemSize = NSCollectionLayoutSize(widthDimension: NSCollectionLayoutDimension.absolute(148), heightDimension: NSCollectionLayoutDimension.absolute(200))
            let item = NSCollectionLayoutItem(layoutSize: itemSize)
            
            let groupSize = NSCollectionLayoutSize(widthDimension: .estimated(148), heightDimension: .absolute(200))
            let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
            group.interItemSpacing = .fixed(12)
            
            let sectionLayout = NSCollectionLayoutSection(group: group)
            sectionLayout.orthogonalScrollingBehavior = .continuous
            sectionLayout.interGroupSpacing = 12
            
            let headerSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .estimated(44))
            let header = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: headerSize, elementKind: UICollectionView.elementKindSectionHeader, alignment: .topLeading)
            sectionLayout.boundarySupplementaryItems = [header]
            
            return sectionLayout
        }
    }
}
