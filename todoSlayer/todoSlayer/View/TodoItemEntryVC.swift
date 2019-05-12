//
//  TodoItemEntryVC.swift
//  todoSlayer
//
//  Created by Kalyani shiva on 09/05/19.
//  Copyright © 2019 Kalyani shiva. All rights reserved.
//

import UIKit
import SnapKit

class TodoItemEntryVC: UIViewController {
    
    private var viewModel: TodoEntryViewModel!
    
    private let taskNameTextField: UITextField = {
        let tf = UITextField()
        tf.translatesAutoresizingMaskIntoConstraints = false
        tf.placeholder = "Enter Task Name!"
        tf.backgroundColor = UIColor(red:0.96, green:0.96, blue:0.96, alpha:1.0)
        return tf
    }()
    
    private let taskNotesTextView: UITextView = {
        let tv = UITextView()
        tv.translatesAutoresizingMaskIntoConstraints = false
        tv.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        tv.text = "OMG"
        tv.backgroundColor = UIColor(red:0.96, green:0.96, blue:0.96, alpha:1.0)
        return tv
    }()
    
    private lazy var addButton: UIButton = {
        let btn = UIButton()
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.titleLabel?.font = UIFont.systemFont(ofSize: 20, weight: .medium)
        btn.setTitleColor(#colorLiteral(red: 0.9333333333, green: 0.9843137255, blue: 0.9843137255, alpha: 1), for: .normal)
        btn.setTitle("Add Task", for: .normal)
        btn.backgroundColor = #colorLiteral(red: 0.4607380033, green: 0.3224592209, blue: 1, alpha: 1)
        btn.addTarget(self, action: #selector(handleAddTask), for: .touchUpInside)
        return btn
    }()
    
    private lazy var stackView: UIStackView = {
        let sv = UIStackView()
        sv.translatesAutoresizingMaskIntoConstraints = false
        sv.axis = .vertical
        sv.alignment = UIStackView.Alignment.fill
        sv.distribution = UIStackView.Distribution.equalCentering
        sv.isLayoutMarginsRelativeArrangement = true
        sv.layoutMargins = UIEdgeInsets(top: 125, left: 50, bottom: 150, right: 50)
        sv.spacing = 20
        sv.setCustomSpacing(10, after: taskNotesTextView)
        return sv
    }()
    
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        return scrollView
    }()
    
    private let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.masksToBounds = true
        view.layer.cornerRadius = 10
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowRadius = 10
        view.layer.shadowOpacity = 1
        return view
    }()
    
    private lazy var closeButton: UIButton = {
        let btn = UIButton()
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.layer.masksToBounds = false
        btn.addTarget(self, action: #selector(handleClose), for: .touchUpInside)
        btn.backgroundColor = #colorLiteral(red: 0.9254902005, green: 0.2352941185, blue: 0.1019607857, alpha: 1)
        btn.setImage(UIImage(named: "close"), for: .normal)
        btn.imageEdgeInsets = UIEdgeInsets(top: 7, left: 7, bottom: 7, right: 7)
        return btn
    }()
    
    override func viewDidLayoutSubviews() {
        containerView.layer.shadowPath = UIBezierPath(rect: view.bounds).cgPath
        scrollView.contentSize = CGSize(width: view.bounds.width, height: view.bounds.height * 1.1)
        closeButton.layer.cornerRadius = closeButton.frame.width * 0.5
    }
    
    override func viewDidLoad() {
        viewModel = TodoEntryViewModel(delegate: self)
        setupScrollView()
        setupCloseButton()
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard)))
        view.backgroundColor = #colorLiteral(red: 0.9098039269, green: 0.4784313738, blue: 0.6431372762, alpha: 1)
        
        setupStackView()
        setupStackViewBackground()
        setupStackViewArrangedSubviews()
    }
}


// MARK:- View Layout Code
extension TodoItemEntryVC {
    
    private func setupStackView() {
        scrollView.addSubview(stackView)
        stackView.snp.makeConstraints { (make) in
            make.top.equalTo(scrollView)
            make.leading.equalTo(scrollView)
            make.height.equalTo(view)
            make.width.equalTo(view)
        }
    }
    
    private func setupStackViewBackground() {
        stackView.addSubview(containerView)
        containerView.snp.makeConstraints { (make) in
            make.top.equalTo(stackView.snp.topMargin).offset(-10)
            make.leading.equalTo(stackView.snp.leadingMargin).offset(-10)
            make.trailing.equalTo(stackView.snp.trailingMargin).offset(10)
            make.bottom.equalTo(stackView.snp.bottomMargin).offset(10)
        }
    }
    
    private func setupStackViewArrangedSubviews() {
        stackView.addArrangedSubview(taskNameTextField)
        stackView.addArrangedSubview(taskNotesTextView)
        stackView.addArrangedSubview(addButton)
        
        taskNameTextField.heightAnchor.constraint(equalToConstant: 70).isActive = true
        taskNotesTextView.heightAnchor.constraint(equalToConstant: 200).isActive = true
        addButton.heightAnchor.constraint(equalToConstant: 60).isActive = true
    }
    
    private func setupScrollView() {
        view.addSubview(scrollView)
        scrollView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
    }
    
    private func setupCloseButton() {
        view.addSubview(closeButton)
        closeButton.snp.makeConstraints { (make) in
            make.height.width.equalTo(35)
            make.trailing.equalTo(view).offset(-30)
            make.top.equalTo(view).offset(50)
        }
    }
}


extension TodoItemEntryVC {
    
    @objc private func dismissKeyboard() {
        taskNameTextField.resignFirstResponder()
        taskNotesTextView.resignFirstResponder()
    }
    
    @objc private func handleAddTask() {
        viewModel.taskName = taskNameTextField.text
        viewModel.taskNotes = taskNotesTextView.text
        viewModel.addTask()
    }
    
    @objc private func handleClose() {
        self.dismiss(animated: true, completion: nil)
    }
}

extension TodoItemEntryVC: TodoEntryViewModelDelegate {
    
    func didAddTask() {
        showAlertView(message: "Task Added!😎", title: "Yay!", shouldDismiss: true)
    }
    
    func handleFailure(_ failure: TaskEntryFailure) {
        switch failure {
        case .taskNameMissing:
            showAlertView(message: "Task Name is mandatory!")
        }
    }
}

extension TodoItemEntryVC {
    private func showAlertView(message: String, title: String = "Woops", shouldDismiss: Bool = false) {
        let alertView = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertView.addAction(UIAlertAction(title: "Okay 👍", style: .default, handler: { (_) in
            guard shouldDismiss == true else { return }
            self.dismiss(animated: true, completion: nil)
        }))
        present(alertView, animated: true)
    } // showAlertView func ends ...
    
} // extension ends ...
