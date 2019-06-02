//
//  TodoItemEntryVC.swift
//  todoSlayer
//
//  Created by Kalyani shiva on 09/05/19.
//  Copyright © 2019 Kalyani shiva. All rights reserved.
//

import UIKit
import SnapKit
import CVCalendar

class TodoDetailVC: UIViewController {
    
    private var todoItem: TodoItem! = nil {
        didSet {
            guard let todoItem = todoItem else { return }
            taskNameTextField.text = todoItem.name
            taskNotesTextField.text = todoItem.notes
            priorityButton.setTitle(todoItem.priority.getName(), for: .normal)
        }
    }
    
    private var todoItemIndexPath: IndexPath?
    
    enum Mode {
        case newTodoItem
        case existingTodoItem(TodoItem, IndexPath)
    }
    
    private var mode: Mode
    
    private var viewModel: TodoEntryViewModel!
    
    private let taskNameTextField: UITextField = {
        let tf = UITextField()
        tf.translatesAutoresizingMaskIntoConstraints = false
        tf.placeholder = "Enter task name."
        tf.backgroundColor = UIColor(red: 0.96, green: 0.96, blue: 0.96, alpha: 1.0)
        return tf
    }()
    
    private let taskNotesTextField: UITextField = {
        let tv = UITextField()
        tv.translatesAutoresizingMaskIntoConstraints = false
        tv.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        tv.text = "Enter notes."
        tv.backgroundColor = UIColor(red:0.96, green:0.96, blue:0.96, alpha:1.0)
        return tv
    }()
    
    private lazy var addButton: UIButton = {
        let btn = UIButton()
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.titleLabel?.font = UIFont.systemFont(ofSize: 20, weight: .medium)
        btn.setTitleColor(#colorLiteral(red: 0.9333333333, green: 0.9843137255, blue: 0.9843137255, alpha: 1), for: .normal)
        btn.setTitle("Add Task", for: .normal)
        btn.backgroundColor = #colorLiteral(red: 0.3411764801, green: 0.6235294342, blue: 0.1686274558, alpha: 1)
        btn.addTarget(self, action: #selector(handleAddTask), for: .touchUpInside)
        return btn
    }()
    
    private lazy var deleteButton: UIButton = {
        let btn = UIButton()
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.titleLabel?.font = UIFont.systemFont(ofSize: 20, weight: .medium)
        btn.setTitleColor(#colorLiteral(red: 0.9333333333, green: 0.9843137255, blue: 0.9843137255, alpha: 1), for: .normal)
        btn.setTitle("Delete Task", for: .normal)
        btn.backgroundColor = #colorLiteral(red: 1, green: 0.1491314173, blue: 0, alpha: 1)
        btn.addTarget(self, action: #selector(handleDeleteTask), for: .touchUpInside)
        return btn
    }()
    
    private lazy var updateButton: UIButton = {
        let btn = UIButton()
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.titleLabel?.font = UIFont.systemFont(ofSize: 20, weight: .medium)
        btn.setTitleColor(#colorLiteral(red: 0.9333333333, green: 0.9843137255, blue: 0.9843137255, alpha: 1), for: .normal)
        btn.setTitle("Update Task", for: .normal)
        btn.backgroundColor = #colorLiteral(red: 0.2392156869, green: 0.6745098233, blue: 0.9686274529, alpha: 1)
        btn.addTarget(self, action: #selector(handleUpdateTask), for: .touchUpInside)
        btn.isEnabled = false
        btn.alpha = 0.5
        return btn
    }()
    
    private lazy var dueDateButton: UIButton = {
        let btn = UIButton()
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.titleLabel?.font = UIFont.systemFont(ofSize: 20, weight: .medium)
        btn.setTitleColor(#colorLiteral(red: 0.9333333333, green: 0.9843137255, blue: 0.9843137255, alpha: 1), for: .normal)
        btn.setTitle("Choose Due Date", for: .normal)
        btn.backgroundColor = #colorLiteral(red: 0.5568627715, green: 0.3529411852, blue: 0.9686274529, alpha: 1)
        btn.addTarget(self, action: #selector(handleDueDate), for: .touchUpInside)
        return btn
    }()
    
    private lazy var reminderDateButton: UIButton = {
        let btn = UIButton()
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.titleLabel?.font = UIFont.systemFont(ofSize: 20, weight: .medium)
        btn.setTitleColor(#colorLiteral(red: 0.9333333333, green: 0.9843137255, blue: 0.9843137255, alpha: 1), for: .normal)
        btn.setTitle("Choose Reminder Date", for: .normal)
        btn.backgroundColor = #colorLiteral(red: 0.8549019694, green: 0.250980407, blue: 0.4784313738, alpha: 1)
        btn.addTarget(self, action: #selector(handleReminderDate), for: .touchUpInside)
        return btn
    }()
    
    private lazy var priorityButton: UIButton = {
        let btn = UIButton()
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.titleLabel?.font = UIFont.systemFont(ofSize: 20, weight: .medium)
        btn.setTitleColor(#colorLiteral(red: 0.9333333333, green: 0.9843137255, blue: 0.9843137255, alpha: 1), for: .normal)
        btn.setTitle("Choose Priority", for: .normal)
        btn.backgroundColor = #colorLiteral(red: 0.9607843161, green: 0.7058823705, blue: 0.200000003, alpha: 1)
        btn.addTarget(self, action: #selector(handlePriority), for: .touchUpInside)
        return btn
    }()
    
    private lazy var stackView: UIStackView = {
        let sv = UIStackView()
        sv.translatesAutoresizingMaskIntoConstraints = false
        sv.axis = .vertical
        sv.alignment = UIStackView.Alignment.fill
        sv.distribution = UIStackView.Distribution.equalCentering
        sv.isLayoutMarginsRelativeArrangement = true
        sv.layoutMargins = UIEdgeInsets(top: 125, left: 50, bottom: 50, right: 50)
        sv.spacing = 20
        sv.setCustomSpacing(10, after: taskNotesTextField)
        return sv
    }()
    
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        return scrollView
    }()
    
    private let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = #colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1)
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
        btn.backgroundColor = #colorLiteral(red: 0.9607843161, green: 0.7058823705, blue: 0.200000003, alpha: 1)
        btn.setImage(UIImage(named: "close"), for: .normal)
        btn.imageEdgeInsets = UIEdgeInsets(top: 7, left: 7, bottom: 7, right: 7)
        return btn
    }()
    
    
    private lazy var calenderView: CVCalendarView = {
        let calenderView = CVCalendarView()
        calenderView.translatesAutoresizingMaskIntoConstraints = false
        calenderView.delegate = self
        return calenderView
    }()
    
    
    init(mode: Mode) {
        self.mode = mode
        super.init(nibName: nil, bundle: nil)
        reflectModeChanges()
    }
    
    private func reflectModeChanges() {
        if case let .existingTodoItem(todoItem, indexPath) = self.mode {
            self.todoItem = todoItem
            self.todoItemIndexPath = indexPath
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
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
        view.backgroundColor = .black
        
        setupStackView()
        setupStackViewBackground()
        setupStackViewArrangedSubviews()
        
        taskNameTextField.addTarget(self, action: #selector(handleTextFieldTap), for: .editingDidBegin)
        taskNotesTextField.addTarget(self, action: #selector(handleTextFieldTap), for: .editingDidBegin)
        taskNameTextField.addTarget(self, action: #selector(handleTextFieldEvent(textField:)), for: .editingChanged)
        taskNotesTextField.addTarget(self, action: #selector(handleTextFieldEvent(textField:)), for: .editingChanged)
    }
}


// MARK:- View Layout Code
extension TodoDetailVC {
    
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
        stackView.addArrangedSubview(taskNotesTextField)
        
        stackView.addArrangedSubview(priorityButton)
        stackView.addArrangedSubview(dueDateButton)
        stackView.addArrangedSubview(reminderDateButton)
        
        switch mode {
        case .newTodoItem:
            stackView.addArrangedSubview(addButton)
        case .existingTodoItem(_):
            stackView.addArrangedSubview(updateButton)
            stackView.addArrangedSubview(deleteButton)
        }
        
        taskNameTextField.heightAnchor.constraint(equalToConstant: 70).isActive = true
        taskNotesTextField.heightAnchor.constraint(equalToConstant: 200).isActive = true
        
        addButton.heightAnchor.constraint(equalToConstant: 60).isActive = true
        deleteButton.heightAnchor.constraint(equalToConstant: 60).isActive = true
        updateButton.heightAnchor.constraint(equalToConstant: 60).isActive = true
        priorityButton.heightAnchor.constraint(equalToConstant: 60).isActive = true
        
        reminderDateButton.heightAnchor.constraint(equalToConstant: 60).isActive = true
        dueDateButton.heightAnchor.constraint(equalToConstant: 60).isActive = true
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

// MARK:- Event Handling
extension TodoDetailVC {
    
    @objc private func handleTextFieldEvent(textField: UITextField) {
        if textField == taskNameTextField {
            if textField.text != todoItem?.name {
                updateButton.enable()
            } else {
                updateButton.disable()
            }
        } else {
            if textField.text != todoItem?.notes {
                updateButton.enable()
            } else {
                updateButton.disable()
            }
        }
    }
    
    @objc private func handleTextFieldTap() {
        scrollView.setContentOffset(CGPoint(x: 0, y: 50), animated: true)
    }
    
    @objc private func dismissKeyboard() {
        taskNameTextField.resignFirstResponder()
        taskNotesTextField.resignFirstResponder()
    }
    
    @objc private func handleAddTask() {
        viewModel.taskName = taskNameTextField.text
        viewModel.taskNotes = taskNotesTextField.text ?? ""
        viewModel.addTodoItem()
    }
    
    @objc private func handleDeleteTask() {
        guard let todoItem = todoItem else {
            print("Invalid State ! No Todo Item to delete!")
            return
        }
        viewModel.deleteTodoItem(todoItem, atIndexPath: todoItemIndexPath!)
    }
    
    @objc private func handleUpdateTask() {
        
        guard let todoItem = todoItem else {
            Logger.log(reason: "Update task failed! There is no todo Item!")
            return
        }
        
        guard let name = taskNameTextField.text, let notes = taskNotesTextField.text else {
            Logger.log(reason: "Required fields are nil! Update failed!")
            return
        }
        
        todoItem.name = name
        todoItem.notes = notes
        
        viewModel.updateTodoItem(todoItem)
    }
    
    @objc private func handleClose() {
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc private func handleDueDate() {
        //        view.addSubview(calenderView)
        //        calenderView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        //        calenderView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        //        calenderView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        //        calenderView.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.5).isActive = true
    }
    
    @objc private func handleReminderDate() {
        
    }
    
    @objc private func handlePriority() {
        let alertView = UIAlertController(title: "Choose Priority", message: "", preferredStyle: .actionSheet)
        alertView.addAction(UIAlertAction(title: "High", style: .default) { (_) in
            self.viewModel.taskPriority = .high
            self.updateTaskPriority(.high)
            self.priorityButton.setTitle(TaskPriority.high.getName(), for: .normal)
        })
        alertView.addAction(UIAlertAction(title: "Medium", style: .default) { (_) in
            self.viewModel.taskPriority = .medium
            self.updateTaskPriority(.medium)
            self.priorityButton.setTitle(TaskPriority.medium.getName(), for: .normal)
        })
        alertView.addAction(UIAlertAction(title: "Low", style: .default) { (_) in
            self.viewModel.taskPriority = .low
            self.updateTaskPriority(.low)
            self.priorityButton.setTitle(TaskPriority.low.getName(), for: .normal)
        })
        alertView.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        present(alertView, animated: true, completion: nil)
    }
    
    private func updateTaskPriority(_ priority: TaskPriority) {
        guard todoItem != nil else { return }
        guard self.todoItem.priority != priority else { return }
        self.todoItem.priority = priority
        updateButton.enable()
    }
    
}

extension TodoDetailVC: TodoEntryViewModelDelegate {
    
    func didCompleteOperation(_ operation: ListOperation) {
        
        switch operation {
            
        case .add:
            didAddTask()
            
        case .delete:
            didDeleteTask()
            
        case .update:
            didUpdateTask()
            
        case .reorder:
            fatalError("Invalid operation!")
            
        }
        
    }
    
    private func didUpdateTask() {
        showAlertView(message: "Task Updated!😎", title: "Yupp!", shouldDismiss: true)
    }
    
    private func didAddTask() {
        showAlertView(message: "Task Added!😎", title: "Yay!", shouldDismiss: true)
    }
    
    private func didDeleteTask() {
        showAlertView(message: "Task Deleted 🙆‍♂️", title: "Gone", shouldDismiss: true)
    }
    
    func handleFailure(_ failure: TaskEntryFailure) {
        switch failure {
        case .taskNameMissing:
            showAlertView(message: "Task Name is mandatory!")
        }
    }
}

extension TodoDetailVC {
    private func showAlertView(message: String, title: String = "Woops", shouldDismiss: Bool = false) {
        let alertView = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertView.addAction(UIAlertAction(title: "Okay 👍", style: .default, handler: { (_) in
            guard shouldDismiss == true else { return }
            self.dismiss(animated: true, completion: nil)
        }))
        present(alertView, animated: true)
    } // showAlertView func ends ...
    
} // extension ends ...

extension TodoDetailVC: CVCalendarViewDelegate {
    
    func presentationMode() -> CalendarMode {
        return .monthView
    }
    
    func firstWeekday() -> Weekday {
        return .monday
    }
    
}
