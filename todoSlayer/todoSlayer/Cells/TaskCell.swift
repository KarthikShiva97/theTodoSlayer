//
//  TaskCell.swift
//  todoSlayer
//
//  Created by Kalyani shiva on 12/05/19.
//  Copyright © 2019 Kalyani shiva. All rights reserved.
//

import UIKit

class TaskCell: UICollectionViewCell {
    
    static let taskNameFont = UIFont(name: "Helvetica Neue", size: 18)
    static let sidePadding: CGFloat = 29
    static let topBottomPadding: CGFloat = 21.5
    
    private let taskNameLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = taskNameFont
        label.numberOfLines = 0
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: .zero)
        backgroundColor = #colorLiteral(red: 0.1137254902, green: 0.1254901961, blue: 0.1529411765, alpha: 0.7)
        layer.masksToBounds = true
        layer.cornerRadius = 10
        setupLayout()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(with todoItem: TodoItemListModel) {
        taskNameLabel.text = todoItem.name
        taskNameLabel.textColor = todoItem.textColor
    }
    
    private func setupLayout() {
        addSubview(taskNameLabel)
        taskNameLabel.snp.makeConstraints { (make) in
            make.leading.equalToSuperview().offset(TaskCell.sidePadding)
            make.trailing.equalToSuperview().offset(-TaskCell.sidePadding)
            make.top.equalToSuperview().offset(TaskCell.topBottomPadding)
            make.bottom.equalToSuperview().offset(-TaskCell.topBottomPadding)
        }
    }
}
