//
//  ListOfToDosViewController.swift
//  RealmApp
//
//  Created by ульяна on 11.01.23.
//

import UIKit
import RealmSwift

final class ListOfToDosViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    var notificationToken: NotificationToken?
    
    let control = UISegmentedControl(items: ["A-Z", "Sort by Data"])
    var taskLists: Results<TasksList>?
    var tableView: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()
        setUpSegmentedControll()
        setupTableView()
        taskLists = StorageManager.getAllTasksLists().sorted(byKeyPath: "name")
        addTaskListObserver()
        
        view.backgroundColor = .white
        tableView.backgroundColor = .clear
        navigationItem.title = "ToDos List"
                
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Add", style: .plain, target: self, action: #selector(addTapped))
        let add = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addTapped))
        
        navigationItem.rightBarButtonItems = [add]
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if let index = self.tableView.indexPathForSelectedRow {
            self.tableView.deselectRow(at: index, animated: true)
        }
    }
    
    private func setupTableView() {
        let tableView = UITableView()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(tableView)
        tableView.topAnchor.constraint(equalTo: self.control.bottomAnchor, constant: 20).isActive = true
        tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        tableView.register(ToDoTableViewCell.self, forCellReuseIdentifier: "cell")
        tableView.estimatedRowHeight = 100
        tableView.rowHeight = UITableView.automaticDimension
        self.tableView = tableView
       }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        100
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as? ToDoTableViewCell else {
            return UITableViewCell()
        }
        guard let taskList = taskLists?[indexPath.row] else { return UITableViewCell() }
        let backgroundView = UIView()
        backgroundView.backgroundColor = UIColor(red: 0.41, green: 0.07, blue: 0.85, alpha: 1.00)
        cell.selectedBackgroundView = backgroundView
        cell.title.highlightedTextColor = .white
        cell.numberOfCompletedTasks.highlightedTextColor = .white
        cell.setUpCell(with: taskList)
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let taskList = taskLists {
            return taskList.count
        } else {
            return 0
        }
    }
    
    @objc func addTapped(_ sender:UIButton!) {
        alertForAddAndUpdatesListTasks()
    }
    
    func setUpSegmentedControll() {
        
        self.control.addTarget(self, action: #selector(segmentControl(_:)), for: .valueChanged)
        self.control.backgroundColor = UIColor(red: 0.41, green: 0.07, blue: 0.85, alpha: 1.00)
        self.control.layer.cornerRadius = 20
        self.control.selectedSegmentTintColor = UIColor(red: 0.80, green: 0.68, blue: 0.94, alpha: 1.00)
        let titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
        control.setTitleTextAttributes(titleTextAttributes, for: .normal)
        let titleTextAttributesSelected = [NSAttributedString.Key.foregroundColor: UIColor.black]
        control.setTitleTextAttributes(titleTextAttributesSelected, for: .selected)
        
        self.control.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(self.control)

        control.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 100).isActive = true
        control.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 14).isActive = true
        control.heightAnchor.constraint(equalToConstant: 50).isActive = true
        control.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -14).isActive = true
        self.control.selectedSegmentIndex = 0
    }
    
    @objc func segmentControl(_ segmentedControl: UISegmentedControl) {
       switch (segmentedControl.selectedSegmentIndex) {
          case 0:
           taskLists = taskLists?.sorted(byKeyPath: "name")
           break
          case 1:
           taskLists = taskLists?.sorted(byKeyPath: "date")
          break
          default:
          break
       }
    }
    
    private func alertForAddAndUpdatesListTasks(_ taskList: TasksList? = nil ) {
        
        let title = taskList == nil ? "New List" : "Edit List"
        let message = "Please insert list name"
        let doneButtonName = taskList == nil ? "Save" : "Update"
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        var alertTextField: UITextField!
     
        let saveAction = UIAlertAction(title: doneButtonName, style: .default) { _ in
            guard let newListName = alertTextField.text,
                  !newListName.isEmpty else {
                return
            }
            if let tasksList = taskList {
                StorageManager.editList(tasksList, newListName: newListName)
            } else {
                let tasksList = TasksList()
                tasksList.name = newListName
                StorageManager.saveTasksList(taskList: tasksList)
            }
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .destructive)
        
        alert.addAction(saveAction)
        alert.addAction(cancelAction)
        
        alert.addTextField { textField in
            alertTextField = textField
            if let listName = taskList {
                alertTextField.text = listName.name
            }
            alertTextField.placeholder = "List Name"
        }
        present(alert,animated: true)
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        guard let taskLists = taskLists else { return nil }
        let currentList = taskLists[indexPath.row]
        
        let deleteContextItem = UIContextualAction(style: .destructive, title: "Delete") { _, _, _ in
            StorageManager.deleteList(currentList)
        }
        let editContextItem = UIContextualAction(style: .destructive, title: "Edit") {  _, _, _ in
            self.alertForAddAndUpdatesListTasks(currentList) 
            
        }
        let doneContextItem = UIContextualAction(style: .destructive, title: "Done") { _, _, _ in
            StorageManager.makeAllDone(currentList)
        }
        
        editContextItem.backgroundColor = UIColor(red: 0.41, green: 0.07, blue: 0.85, alpha: 1.00)
        deleteContextItem.backgroundColor = .red
        doneContextItem.backgroundColor = .green
        
        let swipeActions = UISwipeActionsConfiguration(actions: [deleteContextItem, editContextItem, doneContextItem])
        
        return swipeActions
    }
     
     func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
         let vc = TasksViewController()
         let currentTaskList = taskLists?[indexPath.row]
         vc.currentTaskList = currentTaskList
         self.navigationController?.pushViewController(vc, animated: true)
     }
    
    private func addTaskListObserver() {
        notificationToken = taskLists?.observe { [weak self] change in
            guard let self = self else {return}
            switch change {
            case .initial:
                print("initial element")
            case .update(_, let deletions, let insertions, let modifications):
                print("deletions: \(deletions)")
                print("insertions: \(insertions)")
                print("modifications: \(modifications)")
                if !modifications.isEmpty {
                    let indexPathArray = self.createIndexPathArray(intArray: modifications)
                    self.tableView.reloadRows(at: indexPathArray, with: .automatic)
                }
                if !deletions.isEmpty {
                    let indexPathArray = self.createIndexPathArray(intArray: deletions)
                    self.tableView.deleteRows(at: indexPathArray, with: .automatic)
                }
                if !insertions.isEmpty {
                    let indexPathArray = self.createIndexPathArray(intArray: insertions)
                    self.tableView.insertRows(at: indexPathArray, with: .automatic)
                }
            case .error(let error):
                print("error: \(error)")
            }
        }
    }
    
    private func createIndexPathArray(intArray: [Int]) -> [IndexPath] {
        var indexPathArray = [IndexPath]()
        for row in intArray {
            indexPathArray.append(IndexPath(row: row, section: 0))
        }
        return indexPathArray
    }
}
