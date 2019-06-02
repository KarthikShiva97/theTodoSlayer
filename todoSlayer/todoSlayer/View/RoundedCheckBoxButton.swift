//
//  CheckBoxButton.swift
//  todoSlayer
//
//  Created by Kalyani shiva on 01/06/19.
//  Copyright © 2019 Kalyani shiva. All rights reserved.
//

import UIKit

class RoundedCheckBoxButton: UIButton {
    
    var isChecked: Bool = true {
        didSet {
            cirlceView.backgroundColor =  isChecked ? checkBoxColor : nil
        }
    }
    
    var checkBoxColor: UIColor = .red {
        didSet {
            layer.borderColor = checkBoxColor.cgColor
            cirlceView.backgroundColor = checkBoxColor
        }
    }
    
    var borderWidth: CGFloat = 1.5 {
        didSet {
            layer.borderWidth = borderWidth
        }
    }
    
    override var backgroundColor: UIColor? {
        didSet {
            super.backgroundColor = nil
        }
    }
    
    func toggle() {
        isChecked = !isChecked
    }
    
    private lazy var cirlceView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = checkBoxColor
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: .zero)
        layer.borderColor = checkBoxColor.cgColor
        layer.borderWidth = borderWidth
        backgroundColor = .clear
        setupLayout()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        cirlceView.layer.cornerRadius = frame.width * 0.3
        layer.cornerRadius = frame.width * 0.5
    }
    
    private func setupLayout() {
        addSubview(cirlceView)
        cirlceView.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview()
            make.width.height.equalTo(snp.width).multipliedBy(0.5652)
        }
    }
}
