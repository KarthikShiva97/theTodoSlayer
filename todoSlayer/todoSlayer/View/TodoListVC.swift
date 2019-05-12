//
//  ViewController.swift
//  todoSlayer
//
//  Created by Kalyani shiva on 05/05/19.
//  Copyright © 2019 Kalyani shiva. All rights reserved.
//

import UIKit
import RealmSwift
import Realm

class TodoListVC: UIViewController {
    
    private let viewModel = TodoListViewModel()
    
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
        view.backgroundColor = .yellow
        return view
    }()
    
    private lazy var collectionView: UICollectionView = {
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.scrollDirection = .vertical
        
        let cv = UICollectionView(frame: .zero, collectionViewLayout: flowLayout)
        cv.translatesAutoresizingMaskIntoConstraints = false
        cv.showsVerticalScrollIndicator = false
        
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
        title = "Todo Killer"
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 25, weight: .medium)]
        setupTopContainer()
        setupCollectionView()
        setupNewTaskButton()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        collectionView.reloadData()
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

// MARK:- Logic Handling
extension TodoListVC {
    @objc private func handleNewTask() {
        let todoItemEntryVC = TodoItemEntryVC()
        present(todoItemEntryVC, animated: true, completion: nil)
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
        
        let width = (collectionView.frame.width - (TaskCell.sidePadding * 2))
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
    
}
