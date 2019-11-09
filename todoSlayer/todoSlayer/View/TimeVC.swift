//
//  TimeVC.swift
//  
//
//  Created by Kalyani shiva on 17/08/19.
//

import UIKit

protocol TimeVCDelegate: class {
    func dismiss(selectedTime: Date?)
}

class TimeVC: UIView {
    
    private weak var delegate: TimeVCDelegate?
    
    private lazy var navBar: UINavigationBar = {
        let bar = UINavigationBar()
        bar.translatesAutoresizingMaskIntoConstraints = false
        
        let navigationItem = UINavigationItem()
        navigationItem.title = "Choose Time"
        
        let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(handleDone))
        let cancelButton = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(handleCancel))
        
        navigationItem.leftBarButtonItem = cancelButton
        navigationItem.rightBarButtonItem = doneButton
        
        bar.items = [navigationItem]
        return bar
    }()
    
    private lazy var timePicker: UIDatePicker = {
        let timePicker = UIDatePicker()
        timePicker.datePickerMode = .time
        timePicker.addTarget(self, action: #selector(handleTimeChange), for: .valueChanged)
        return timePicker
    }()
    
    private var currentTime = Date()
    
    init(delegate: TimeVCDelegate) {
        super.init(frame: .zero)
        backgroundColor = .white
        self.delegate = delegate
        setupLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        layer.masksToBounds = true
        layer.cornerRadius = 10
    }
    
    private func setupLayout() {
        addSubview(timePicker)
        timePicker.snp.makeConstraints {
            $0.bottom.top.leading.trailing.equalToSuperview()
        }
        addSubview(navBar)
        navBar.snp.makeConstraints {
            $0.leading.trailing.top.equalToSuperview()
            $0.height.equalTo(44)
        }
    }
}

extension TimeVC {
    @objc private func handleTimeChange(sender: UIDatePicker) {
        currentTime = sender.date
    }
    
    @objc private func handleDone() {
        delegate?.dismiss(selectedTime: currentTime)
    }
    
    @objc private func handleCancel() {
        delegate?.dismiss(selectedTime: nil)
    }
}
