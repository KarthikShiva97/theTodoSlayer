//
//  ViewController.swift
//  todoSlayer
//
//  Created by Kalyani shiva on 05/05/19.
//  Copyright © 2019 Kalyani shiva. All rights reserved.
//

import UIKit

class TodoListVC: UIViewController {
    
    private lazy var viewModel = TodoListViewModel(delegate: self)
    
    private lazy var newTaskButton: UIButton = {
        let btn = UIButton()
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.layer.masksToBounds = false
        btn.addTarget(self, action: #selector(handleNewTask), for: .touchUpInside)
        btn.backgroundColor = #colorLiteral(red: 0.2156862745, green: 0.5019607843, blue: 0.7294117647, alpha: 1)
        btn.setImage(UIImage(named: "add"), for: .normal)
        btn.imageEdgeInsets = UIEdgeInsets(top: 7, left: 7, bottom: 7, right: 7)
        return btn
    }()
    
    private lazy var segmentedControl: UISegmentedControl = {
        let view = UISegmentedControl(items: ["Pending", "Completed"])
        view.translatesAutoresizingMaskIntoConstraints = false
        view.selectedSegmentIndex = 0
        let attributes = [NSAttributedString.Key.font: UIFont(name: "Avenir-Medium", size: 14) as Any,
                          NSAttributedString.Key.foregroundColor: #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)]
        view.setTitleTextAttributes(attributes, for: .normal)
        view.setTitleTextAttributes(attributes, for: .selected)
        view.tintColor = #colorLiteral(red: 0.1882352941, green: 0.1921568627, blue: 0.1960784314, alpha: 1)
        view.addTarget(self, action: #selector(handleSegmentChange), for: .valueChanged)
        return view
    }()
    
    private lazy var refreshControl: UIRefreshControl = {
        let view = UIRefreshControl()
        view.tintColor = .white
        view.addTarget(self, action: #selector(handleRefresh), for: .valueChanged)
        return view
    }()
    
    private lazy var activityIndicator: UIActivityIndicatorView = {
        let view = UIActivityIndicatorView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.color = #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)
        view.style = .medium
        return view
    }()
    
    private let activityIndicatorLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "LOADING"
        label.textColor = #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)
        label.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        return label
    }()
    
    private lazy var collectionView: UICollectionView = {
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.scrollDirection = .vertical
        
        let cv = UICollectionView(frame: .zero, collectionViewLayout: flowLayout)
        cv.translatesAutoresizingMaskIntoConstraints = false
        cv.showsVerticalScrollIndicator = false
        cv.bounces = true
        cv.alwaysBounceVertical = true
        cv.refreshControl = refreshControl
        cv.delegate = self
        cv.dragDelegate = self
        cv.dropDelegate = self
        cv.dragInteractionEnabled = true
        cv.register(TaskCell.self, forCellWithReuseIdentifier: TaskCell.name)
        return cv
    }()
    
    lazy var dataSource = makeDataSource()
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLayoutSubviews() {
        newTaskButton.layer.cornerRadius = newTaskButton.frame.width * 0.5
    }
    
    override func viewDidLoad() {
        title = "Office Work"
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .edit, target: self, action: #selector(handleEditButton))
        
        collectionView.dataSource = dataSource
        
        setupSegmentedControl()
        setupCollectionView()
        setupNewTaskButton()
        setupActivityIndicator()
        viewModel.screenDidLoad()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        viewModel.didLeaveScreen()
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        collectionView.collectionViewLayout.invalidateLayout()
    }
}

extension TodoListVC {
    private func makeDataSource() -> UICollectionViewDiffableDataSource<TodoItemSection, TodoItemListModel> {
        UICollectionViewDiffableDataSource(collectionView: collectionView) { (collectionView, indexPath, todoItemListModel) -> UICollectionViewCell? in
            let taskCell = collectionView.dequeueReusableCell(withReuseIdentifier: TaskCell.name,
                                                              for: indexPath) as! TaskCell
            taskCell.configure(with: todoItemListModel)
            return taskCell
        }
    }
}

// MARK:- View Layout Code
extension TodoListVC {
    
    private func setupSegmentedControl() {
        view.addSubview(segmentedControl)
        segmentedControl.snp.makeConstraints { (make) in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(10)
            make.centerX.equalToSuperview()
        }
    }
    
    private func setupCollectionView() {
        view.addSubview(collectionView)
        collectionView.snp.makeConstraints { (make) in
            make.leading.equalTo(view).offset(17)
            make.bottom.equalTo(view)
            make.trailing.equalTo(view).offset(-17)
            make.top.equalTo(segmentedControl.snp.bottom).offset(30)
        }
    }
    
    private func setupNewTaskButton() {
        view.addSubview(newTaskButton)
        newTaskButton.snp.makeConstraints { (make) in
            make.bottom.equalTo(view).offset(-20)
            make.trailing.equalTo(view).offset(-20)
            make.height.width.equalTo(50)
        }
    }
    
    private func setupActivityIndicator() {
        view.addSubview(activityIndicator)
        activityIndicator.snp.makeConstraints { (make) in
            make.centerX.centerY.equalToSuperview()
        }
        
        view.addSubview(activityIndicatorLabel)
        activityIndicatorLabel.snp.makeConstraints { (make) in
            make.top.equalTo(activityIndicator.snp.bottom).offset(10)
            make.centerX.equalTo(activityIndicator)
        }
    }
}

// MARK:- Event Handling
extension TodoListVC {
    
    @objc private func handleNewTask() {
        viewModel.didSelectAddButton()
    }
    
    @objc private func handleEditButton() {
        let alertController = UIAlertController(title: "Sorting Options", message: "", preferredStyle: .actionSheet)
        alertController.addAction(UIAlertAction(title: "Sort by name", style: .default) { _ in
            self.viewModel.sortBy(.name)
        })
        alertController.addAction(UIAlertAction(title: "Sort by priority ✔️ ", style: .default) { _ in
            self.viewModel.sortBy(.priority)
        })
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        present(alertController, animated: true, completion: nil)
    }
    
    @objc private func handleRefresh() {
        viewModel.refresh()
    }
    
    @objc private func handleSegmentChange() {
        let newTaskType: TaskType = segmentedControl.selectedSegmentIndex == 0 ? .pending : .completed
        viewModel.setCurrentTaskType(to: newTaskType)
    }
}


// MARK:- Delegate
extension TodoListVC: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let todoName =  viewModel.getTodoItemName(atIndexPath: indexPath)
        
        let width = (collectionView.frame.width - (TaskCell.leftSidePadding + TaskCell.rightSidePadding))
        let size = CGSize(width: width, height: .greatestFiniteMagnitude)
        let attributes: [NSAttributedString.Key: Any] = [NSAttributedString.Key.font: TaskCell.taskNameFont as Any]
        let height = String(todoName).boundingRect(with: size,
                                                   options: .usesLineFragmentOrigin,
                                                   attributes: attributes, context: nil).height
        let finalHeight = (height + (TaskCell.topBottomPadding * 2) + 5)
        
        return CGSize(width: collectionView.frame.width, height: finalHeight)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 15
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        viewModel.didSelectItem(atIndexPath: indexPath)
    }
    
}

extension TodoListVC: UICollectionViewDragDelegate {
    func collectionView(_ collectionView: UICollectionView,
                        itemsForBeginning session: UIDragSession,
                        at indexPath: IndexPath) -> [UIDragItem] {
        
        return viewModel.getDragItem(atIndexPath: indexPath)
    }
}

extension TodoListVC: UICollectionViewDropDelegate {
    func collectionView(_ collectionView: UICollectionView, performDropWith coordinator: UICollectionViewDropCoordinator) {
        guard let destinationIndexPath = coordinator.destinationIndexPath else { return }
        for item in coordinator.items {
            guard let sourceIndexPath = item.sourceIndexPath else { continue }
            viewModel.moveItem(from: sourceIndexPath, to: destinationIndexPath)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, dropSessionDidUpdate session: UIDropSession, withDestinationIndexPath destinationIndexPath: IndexPath?) -> UICollectionViewDropProposal {
        guard collectionView.hasActiveDrag else {
            return UICollectionViewDropProposal(operation: .forbidden)
        }
        return UICollectionViewDropProposal(operation: .move, intent: .insertAtDestinationIndexPath)
    }
    
}

extension TodoListVC: TodoListViewModelDelegate {
    
    func showLoading() {
        self.activityIndicator.isHidden = false
        self.activityIndicatorLabel.isHidden = false
        self.activityIndicator.startAnimating()
    }
    
    func hideLoading() {
        activityIndicator.isHidden = true
        activityIndicatorLabel.isHidden = true
        activityIndicator.stopAnimating()
    }
    
    func stopRefreshing() {
        refreshControl.endRefreshing()
    }
    
    func openTodoDetailVC(withMode mode: TodoDetailVC.Mode) {
        let todoItemEntryVC = TodoDetailVC(mode: mode)
        navigationController?.pushViewController(todoItemEntryVC, animated: true)
    }
    
    func scrollToItem(atIndexPath indexPath: IndexPath) {
        collectionView.scrollToItem(at: indexPath, at: .top, animated: true)
    }
    
}
