//
//  DateTimeVC.swift
//  todoSlayer
//
//  Created by Kalyani shiva on 11/06/19.
//  Copyright © 2019 Kalyani shiva. All rights reserved.
//

import UIKit
import FSCalendar
import SnapKit

protocol DateTimeVCDelegate: class {
    func didSelectDate(_ date: Date)
}

class DateTimeVC: UIViewController {
    
    enum Mode {
        case new
        case existing(date: Date)
    }
    
    private let mode: Mode
    private weak var delegate: DateTimeVCDelegate?
    private var currentDate = Date()
    private var currentTime = Date()
    
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
    
    private lazy var timeVC: TimeVC = {
        let timeVC = TimeVC(delegate: self)
        timeVC.translatesAutoresizingMaskIntoConstraints = false
        return timeVC
    }()
    
    private lazy var chooseTimeButton: UIButton = {
        let btn = UIButton()
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.titleLabel?.font = UIFont.systemFont(ofSize: 20, weight: .medium)
        btn.setTitleColor(#colorLiteral(red: 0.9333333333, green: 0.9843137255, blue: 0.9843137255, alpha: 1), for: .normal)
        btn.setTitle("Choose Time", for: .normal)
        btn.backgroundColor = #colorLiteral(red: 0.8549019694, green: 0.250980407, blue: 0.4784313738, alpha: 1)
        btn.addTarget(self, action: #selector(handleTimeSelection), for: .touchUpInside)
        return btn
    }()
    
    private var timePickerViewYPositionConstraint: Constraint?
    
    init(mode: Mode, delegate: DateTimeVCDelegate) {
        self.mode = mode
        self.delegate = delegate
        super.init(nibName: nil, bundle: nil)
        view.backgroundColor = .white
        selectDateIfNeeded()
        overrideUserInterfaceStyle = .light
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

private extension DateTimeVC {
    func selectDateIfNeeded() {
        guard case Mode.existing(date: let date) = self.mode else { return }
        calender.select(date, scrollToDate: true)
    }
    
    @objc func handleSet() {
        let dateComponentsFromCalender = Calendar.current.dateComponents([.day,.month,.year,.timeZone],
                                                                         from: currentDate)
        let dateComponentsFromTimePicker = Calendar.current.dateComponents([.hour,.minute,.second],
                                                                           from: currentTime)
        
        var mergedDateComponents = DateComponents()
        mergedDateComponents.day = dateComponentsFromCalender.day
        mergedDateComponents.month = dateComponentsFromCalender.month
        mergedDateComponents.year = dateComponentsFromCalender.year
        mergedDateComponents.timeZone = dateComponentsFromCalender.timeZone
        
        mergedDateComponents.hour = dateComponentsFromTimePicker.hour
        mergedDateComponents.minute = dateComponentsFromTimePicker.minute
        mergedDateComponents.second = dateComponentsFromTimePicker.second
        
        guard let date = Calendar.current.date(from: mergedDateComponents) else {
            dismissVC()
            return
        }
        
        delegate?.didSelectDate(date)
        dismissVC()
    }
    
    @objc private func dismissVC() {
        dismiss(animated: true, completion: nil)
    }
}

//MARK:- Calender Delegate
extension DateTimeVC: FSCalendarDataSource, FSCalendarDelegate {
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

//MARK:- Time Picker Delegate
extension DateTimeVC: TimeVCDelegate {
    func didDismiss(selectedTime: Date?) {
        hideTimeVC()
        guard let selectedTime = selectedTime else { return }
        currentTime = selectedTime
        setSelectedTimeOnButton(selectedTime)
    }
    private func setSelectedTimeOnButton(_ selectedTime: Date) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .none
        dateFormatter.timeStyle = .short
        let timeString = dateFormatter.string(from: selectedTime)
        chooseTimeButton.setTitle(timeString, for: .normal)
    }
}


//MARK:- Time Picker Handling Code
private extension DateTimeVC {
    func hideTimeVC(shouldAnimate: Bool = true) {
        timePickerViewYPositionConstraint?.deactivate()
        timeVC.snp.makeConstraints { make in
            timePickerViewYPositionConstraint = make.top.equalTo(view.snp.bottom).constraint
        }
        timePickerViewYPositionConstraint?.activate()
        let animationDuration: TimeInterval = shouldAnimate ? 0.35 : 0
        UIView.animate(withDuration: animationDuration) {
            self.view.layoutIfNeeded()
        }
    }
    func showTimeVC() {
        timePickerViewYPositionConstraint?.deactivate()
        timeVC.snp.makeConstraints { make in
            timePickerViewYPositionConstraint = make.bottom.equalTo(view.snp.bottom).constraint
        }
        timePickerViewYPositionConstraint?.activate()
        UIView.animate(withDuration: 0.35) {
            self.view.layoutIfNeeded()
        }
    }
    @objc func handleTimeSelection() {
        showTimeVC()
    }
}

//MARK:- View setup code
extension DateTimeVC {
    override func loadView() {
        view = UIView()
        setupViews()
    }
    
    private func setupViews() {
        setupNavBarItems()
        setupCalender()
        setupChooseTimeButton()
        setupTimePicker()
    }
    
    private func setupCalender() {
        view.addSubview(calender)
        calender.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(20)
            make.leading.trailing.equalToSuperview()
            make.bottom.equalToSuperview().multipliedBy(0.5)
        }
    }
    
    private func setupChooseTimeButton() {
        view.addSubview(chooseTimeButton)
        chooseTimeButton.snp.makeConstraints { make in
            make.top.equalTo(calender.snp.bottom).offset(50)
            make.centerX.equalToSuperview()
            make.width.equalTo(120)
        }
    }
    
    private func setupTimePicker() {
        view.addSubview(timeVC)
        timeVC.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(300)
            hideTimeVC(shouldAnimate: false)
        }
    }
    
    private func setupNavBarItems() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Set",
                                                            style: .done,
                                                            target: self,
                                                            action: #selector(handleSet))
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel,
                                                           target: self,
                                                           action: #selector(dismissVC))
    }
}
