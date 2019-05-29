//
//  TaskCell.swift
//  todoSlayer
//
//  Created by Kalyani shiva on 12/05/19.
//  Copyright © 2019 Kalyani shiva. All rights reserved.
//

import UIKit

class TaskCell: UICollectionViewCell {
    
    static let taskNameFont = UIFont(name: "Verdana", size: 16)
    static let rightSidePadding: CGFloat = 15
    static let topBottomPadding: CGFloat = 21.5
    static let leftSidePadding: CGFloat = 54
    
    private let taskNameLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = taskNameFont
        label.numberOfLines = 0
        label.textColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 0.8)
        return label
    }()
    
    private lazy var completeButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(handleComplete), for: .touchUpInside)
        button.layer.borderWidth = 1.5
        button.layer.borderColor = #colorLiteral(red: 0.8156862745, green: 0.007843137255, blue: 0.1058823529, alpha: 1)
        button.layer.cornerRadius = 12
        return button
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
    }
    
    private func setupLayout() {
        addSubview(completeButton)
        completeButton.snp.makeConstraints { (make) in
            make.width.height.equalTo(24)
            make.leading.equalToSuperview().offset(16)
            make.top.equalToSuperview().offset(23)
        }
        
        addSubview(taskNameLabel)
        taskNameLabel.snp.makeConstraints { (make) in
            make.leading.equalTo(completeButton.snp.trailing).offset(18)
            make.trailing.equalToSuperview().offset(-TaskCell.rightSidePadding)
            make.top.equalToSuperview().offset(TaskCell.topBottomPadding)
            make.bottom.equalToSuperview().offset(-TaskCell.topBottomPadding)
        }
    }
    
    @objc private func handleComplete() {
        print("Completed")
    }
}
