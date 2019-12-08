//
//  HomeViewCell.swift
//  todoSlayer
//
//  Created by Kalyani shiva on 08/12/19.
//  Copyright © 2019 Kalyani shiva. All rights reserved.
//

import UIKit

class HomeViewCell: UICollectionViewCell {
    
    private let icon: UIImageView = {
        let iv = UIImageView()
        iv.translatesAutoresizingMaskIntoConstraints = false
        iv.contentMode = .scaleAspectFit
        return iv
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .yellow
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(with list: List) {
        
    }
}
