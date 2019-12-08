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
    
    private lazy var completeButton: RoundedCheckBoxButton = {
        let button = RoundedCheckBoxButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.isUserInteractionEnabled = false
        button.borderWidth = 1.5
        return button
    }()
    
    private lazy var completeActionCaptureButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(handleComplete), for: .touchUpInside)
        return button
    }()
    
    private var checkBoxAction: ((RoundedCheckBoxButton)->())?
    
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
        completeButton.checkBoxColor = todoItem.completeButtonColor
        completeButton.isChecked = todoItem.isCompleted
        checkBoxAction = todoItem.checkBoxAction
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
        
        addSubview(completeActionCaptureButton)
        completeActionCaptureButton.snp.makeConstraints { (make) in
            make.leading.equalToSuperview()
            make.top.bottom.equalToSuperview()
            make.trailing.equalTo(taskNameLabel.snp.leading)
        }
    }
    
    @objc private func handleComplete() {
        checkBoxAction?(completeButton)
    }
}
