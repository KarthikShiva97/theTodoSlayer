//
//  DateTimeVC.swift
//  todoSlayer
//
//  Created by Kalyani shiva on 11/06/19.
//  Copyright © 2019 Kalyani shiva. All rights reserved.
//

import UIKit
import FSCalendar

protocol DateVCDelegate: class {
    func didSelectDate(_ date: Date)
}

class DateVC: UIViewController {
    
    enum Mode {
        case new
        case existing(date: Date)
    }
    
    private let mode: Mode
    private weak var delegate: DateVCDelegate?
    private var currentDate: Date?
    
    private lazy var calender: FSCalendar = {
        let calender = FSCalendar(frame: CGRect(x: 0, y: 0, width: 300, height: 300))
        calender.translatesAutoresizingMaskIntoConstraints = false
        calender.backgroundColor = .white
        calender.delegate = self
        calender.dataSource = self
        return calender
    }()
    
    private var calenderHeightConstraint: NSLayoutConstraint!
    
    private let formatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy/MM/dd zzzz"
        return formatter
    }()
    
    
    init(mode: Mode, delegate: DateVCDelegate) {
        self.mode = mode
        self.delegate = delegate
        super.init(nibName: nil, bundle: nil)
        view.backgroundColor = .white
        selectDateIfNeeded()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(handleCancel))
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(handleDone))
        
        view.addSubview(calender)
        calender.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(20)
            make.leading.trailing.equalToSuperview()
            make.bottom.equalToSuperview().multipliedBy(0.5)
        }
    }
}

private extension DateVC {
    func selectDateIfNeeded() {
        guard case Mode.existing(date: let date) = self.mode else { return }
        calender.select(date, scrollToDate: true)
    }
    
    @objc func handleCancel() {
        dismiss(animated: true, completion: nil)
    }
    
    @objc func handleDone() {
        if let currentDate = currentDate { delegate?.didSelectDate(currentDate) }
        dismiss(animated: true, completion: nil)
    }
}

extension DateVC: FSCalendarDataSource, FSCalendarDelegate {
    
    func maximumDate(for calendar: FSCalendar) -> Date {
        let dateNow = Date()
        let calender = Calendar.current
        return calender.date(byAdding: .year, value: 2, to: dateNow)!
    }
    
    func calendar(_ calendar: FSCalendar, boundingRectWillChange bounds: CGRect, animated: Bool) {
        calendar.snp.updateConstraints { (make) in
            make.height.equalTo(bounds.height * 0.5)
        }
        self.view.layoutIfNeeded()
    }
    
    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
        currentDate = date
    }
}
