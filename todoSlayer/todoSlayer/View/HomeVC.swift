//
//  HomeVC.swift
//  todoSlayer
//
//  Created by Kalyani shiva on 08/12/19.
//  Copyright © 2019 Kalyani shiva. All rights reserved.
//

import UIKit
import SnapKit

class HomeView: UIView {
    lazy var colllectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.translatesAutoresizingMaskIntoConstraints = false
        cv.register(HomeViewCell.self, forCellWithReuseIdentifier: HomeViewCell.name)
        return cv
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupLayout() {
        addSubview(colllectionView)
        colllectionView.snp.makeConstraints {
            $0.leading.trailing.top.bottom.equalToSuperview()
        }
    }
}

class HomeVC: UIViewController, UICollectionViewDelegateFlowLayout {
    
    private var homeView: HomeView {
        return view as! HomeView
    }
    
    private lazy var dataSource = makeDataSource()
    
    override func loadView() {
        view = HomeView()
    }
    
    override func viewDidLoad() {
        homeView.colllectionView.dataSource = dataSource
        homeView.colllectionView.delegate = self
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return .init(width: collectionView.frame.width, height: 100)
    }
}

extension HomeVC {
    private func makeDataSource() -> UICollectionViewDiffableDataSource<List.Section, List> {
        return UICollectionViewDiffableDataSource(collectionView: homeView.colllectionView) { (collectionView,
            indexPath, list) -> UICollectionViewCell? in
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: HomeViewCell.name,
                                                          for: indexPath) as! HomeViewCell
            cell.configure(with: list)
            return cell
        }
    }
    
    func updateTable(shouldAnimate: Bool = true, lists: List...) {
        var snapshot = NSDiffableDataSourceSnapshot<List.Section, List>()
        snapshot.appendSections([.one])
        snapshot.appendItems(lists)
        dataSource.apply(snapshot, animatingDifferences: shouldAnimate)
    }
}



