//
//  ListOfToDosViewController.swift
//  RealmApp
//
//  Created by ульяна on 11.01.23.
//

import UIKit
import RealmSwift

 final class ListOfToDosViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    let control = UISegmentedControl(items: ["A-Z", "Sort by Data"])
    var taskLists: Results<TasksList>?
    var tableView: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()
        setUpSegmentedControll()
        setupTableView()
        view.backgroundColor = .white
        tableView.backgroundColor = .clear
        navigationItem.title = "ToDos List"
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Add", style: .plain, target: self, action: #selector(addTapped))
        let add = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addTapped))
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Edit", style: .plain, target: self, action: #selector(editTapped))
        let edit = UIBarButtonItem(barButtonSystemItem: .edit, target: self, action: #selector(editTapped))

        navigationItem.rightBarButtonItems = [add, edit]
        
//        StorageManager.deleteAll()
        
        taskLists = StorageManager.getAllTasksLists().sorted(byKeyPath: "name")
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
        let taskList = taskLists?[indexPath.row]
        cell.setUpCell(name: taskList?.name ?? "", competed: taskList?.tasks.count.description ?? "")
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
        alertForAddAndUpdatesListTasks { [weak self] in
            print("new list added")
            self?.tableView.reloadData()
        }
    }
    
    @objc func editTapped(_ sender:UIButton!) {
//        let vc = CreatingPostViewController()
//        self.navigationController?.pushViewController(vc, animated: true)
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
        tableView.reloadData()
    }
    
    private func alertForAddAndUpdatesListTasks(_ taskList: TasksList? = nil,
                                                completion: @escaping () -> Void)
    {
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
                StorageManager.editList(tasksList, newListName: newListName, completion: completion)
            } else {
                let tasksList = TasksList()
                tasksList.name = newListName
                StorageManager.saveTasksList(taskList: tasksList)
//                self.tableView.insertRows(at: [IndexPath(row: (self.taskLists?.count ?? 0) - 1, section: 0)], with: .automatic)
                completion()
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
            tableView.reloadRows(at: [indexPath], with: .automatic)
        }
        
        let editeContextItem = UIContextualAction(style: .destructive, title: "Edit") {  _, _, _ in
            self.alertForAddAndUpdatesListTasks(currentList) {
                tableView.reloadRows(at: [indexPath], with: .automatic)
            }
        }
        
        let doneContextItem = UIContextualAction(style: .destructive, title: "Done") { _, _, _ in
            
        }
        
        editeContextItem.backgroundColor = .blue
        deleteContextItem.backgroundColor = .red
        doneContextItem.backgroundColor = .green
        
        let swipeActions = UISwipeActionsConfiguration(actions: [deleteContextItem, editeContextItem, doneContextItem])
        
        return swipeActions
    }
}
