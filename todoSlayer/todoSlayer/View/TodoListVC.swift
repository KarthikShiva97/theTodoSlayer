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
    
    private let topContainer: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var collectionView: UICollectionView = {
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.scrollDirection = .vertical
        
        let cv = UICollectionView(frame: .zero, collectionViewLayout: flowLayout)
        cv.translatesAutoresizingMaskIntoConstraints = false
        cv.showsVerticalScrollIndicator = false
        cv.bounces = true
        cv.alwaysBounceVertical = true
        
        cv.delegate = self
        cv.dataSource = self
        cv.register(TaskCell.self, forCellWithReuseIdentifier: TaskCell.name)
        return cv
    }()
    
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
//        title = "Todo Killer"
//        navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.font: UIFont(name: "Verdana", size: 23)!]
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .edit, target: self, action: #selector(handleEditButton))
        
        collectionView.addGestureRecognizer(UILongPressGestureRecognizer(target: self, action: #selector(handleLongPressGesture(gesture:))))
        
        setupTopContainer()
        setupCollectionView()
        setupNewTaskButton()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        viewModel.willEnterScreen()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        viewModel.didLeaveScreen()
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        collectionView.collectionViewLayout.invalidateLayout()
    }
}

// MARK:- View Layout Code
extension TodoListVC {
    
    private func setupCollectionView() {
        view.addSubview(collectionView)
        collectionView.snp.makeConstraints { (make) in
            make.leading.equalTo(view).offset(17)
            make.bottom.equalTo(view)
            make.trailing.equalTo(view).offset(-17)
            make.top.equalTo(topContainer.snp.bottom)
        }
    }
    
    private func setupTopContainer() {
        view.addSubview(topContainer)
        topContainer.snp.makeConstraints { (make) in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top)
            make.leading.equalTo(view.snp.leading)
            make.trailing.equalTo(view.snp.trailing)
            make.height.equalTo(view).multipliedBy(0.15)
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
}

// MARK:- Event Handling
extension TodoListVC {
    
    @objc private func handleNewTask() {
        viewModel.didSelectAddButton()
    }
    
    @objc private func handleEditButton() {
        let alertController = UIAlertController(title: "Sorting Options", message: "", preferredStyle: .actionSheet)
        alertController.addAction(UIAlertAction(title: "Sort by name", style: .default, handler: nil))
        alertController.addAction(UIAlertAction(title: "Sort by priority", style: .default, handler: nil))
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        present(alertController, animated: true, completion: nil)
    }
}

// MARK:- Data Source
extension TodoListVC: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.getTotalCount()
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let taskCell = collectionView.dequeueReusableCell(withReuseIdentifier: TaskCell.name,
                                                          for: indexPath) as! TaskCell
        taskCell.configure(with: viewModel.getTodoItem(forIndexPath: indexPath))
        return taskCell
    }
    
}

// MARK:- Delegate
extension TodoListVC: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let todoName =  viewModel.getTodoItem(forIndexPath: indexPath).name
        
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
        return 29
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        viewModel.didSelectItem(atIndexPath: indexPath)
    }
    
}

// MARK:- Collection View Cells Reordering
extension TodoListVC {
    
    func collectionView(_ collectionView: UICollectionView, moveItemAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        viewModel.moveItem(from: sourceIndexPath, to: destinationIndexPath)
    }
    
    @objc func handleLongPressGesture(gesture: UILongPressGestureRecognizer) {
        
        switch gesture.state {
            
        case .began:
            guard let selectedIndexPath = collectionView.indexPathForItem(at: gesture.location(in: collectionView)) else {
                print("Reordering Failed! Cannot determine selected IndexPath!")
                collectionView.endInteractiveMovement()
                return
            }
            collectionView.beginInteractiveMovementForItem(at: selectedIndexPath)
            
        case .changed:
            collectionView.updateInteractiveMovementTargetPosition(gesture.location(in: collectionView))
            
        case .ended:
            collectionView.endInteractiveMovement()
            
        case .cancelled:
            collectionView.cancelInteractiveMovement()
            
        default:
            collectionView.cancelInteractiveMovement()
            
        } // switch ends ...
        
    } // func ends ...
    
} // extension ends ...

extension TodoListVC: TodoListViewModelDelegate {
    
    func moveItem(at sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        collectionView.moveItem(at: sourceIndexPath, to: destinationIndexPath)
    }
    
    func openTodoDetailVC(withMode mode: TodoDetailVC.Mode) {
        let todoItemEntryVC = TodoDetailVC(mode: mode)
        present(todoItemEntryVC, animated: true, completion: nil)
    }
    
    func appendItem(_ todoItem: TodoItem, atIndexPath indexPath: IndexPath) {
        collectionView.insertItems(at: [indexPath])
    }
    
    func reloadItem(atIndexPath indexPath: IndexPath) {
        collectionView.reloadItems(at: [indexPath])
    }
    
    func deleteItem(atIndexPath indexPath: IndexPath) {
        collectionView.deleteItems(at: [indexPath])
    }
    
    func scrollToItem(atIndexPath indexPath: IndexPath) {
        collectionView.scrollToItem(at: indexPath, at: .top, animated: true)
    }
    
    func reloadAllItems() {
        collectionView.reloadData()
    }
    
    func reloadAllItemsWithAnimation() {
        collectionView.performBatchUpdates({
            collectionView.reloadSections(IndexSet(integer: 0))
        }, completion: nil)
    }
}
