//
//  TasksViewController.swift
//  RealmApp
//
//  Created by ульяна on 14.01.23.
//

import UIKit
import RealmSwift

enum TasksFlow {
    case addingNewTask
    case editingNewTask(task: Task)
}

struct TextForAlert {
    
    let titleForAlert = "Task Value"
    var messageForAlert: String
    let doneButtonForAlert: String
    let cancelText = "Cancel"
    
    let newTextFieldPlaceholder = "New task"
    let noteTextFieldPlaceholder = "Note"
    
    var taskName: String?
    var taskNote: String?
    
    init(tasksFlow: TasksFlow) {
        switch tasksFlow {
        case .addingNewTask:
            messageForAlert = "Please insert new task value"
            doneButtonForAlert = "Save"
        case .editingNewTask(let task):
            messageForAlert = "Please edit your task"
            doneButtonForAlert = "Update"
            taskName = task.name
            taskNote = task.note
        }
    }
}

class TasksViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    var tableView: UITableView!
    var currentTaskList: TasksList?
    let sectionNameArray = ["Completed tasks", "Outstanding tasks"]
    
    lazy var editBtn = UIBarButtonItem(barButtonSystemItem: .edit, target: self, action: #selector(self.editTapped(_:)))
    lazy var doneBtn = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(self.editTapped(_:)))
    lazy var add = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(self.addTapped(_:)))
    
    private var outstandingTasks: Results<Task>?
    private var completedTasks: Results<Task>?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
        filteringTasks()
        view.backgroundColor = .white
        tableView.backgroundColor = .clear
        navigationItem.title = "\(currentTaskList?.name ?? "")"
        tableView.allowsSelection = false
        navigationItem.rightBarButtonItems = [editBtn, add]
    }
    
    private func setupTableView() {
        let tableView = UITableView()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(tableView)
        tableView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        tableView.register(TaskTableViewCell.self, forCellReuseIdentifier: "cell")
        tableView.estimatedRowHeight = 80
        tableView.rowHeight = UITableView.automaticDimension
        self.tableView = tableView
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        80
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        sectionNameArray.count
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.width, height: 40))
        view.backgroundColor = UIColor(red: 0.41, green: 0.07, blue: 0.85, alpha: 1.00)
        
        let lbl = UILabel(frame: CGRect(x: 15, y: 0, width: view.frame.width - 15, height: 40))
        lbl.textAlignment = .center
        lbl.font = UIFont.systemFont(ofSize: 20)
        lbl.textColor = .white
        lbl.text = sectionNameArray[section]
        view.addSubview(lbl)
        return view
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let completedTasks = completedTasks,
              let outstandingTasks = outstandingTasks else { return 0 }
        return section == 0 ? completedTasks.count : outstandingTasks.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as? TaskTableViewCell else {
            return UITableViewCell()
        }
        let task = indexPath.section == 0 ? completedTasks?[indexPath.row] : outstandingTasks?[indexPath.row]
        cell.setUpCell(name: task?.name ?? "", note: task?.note ?? "")
        return cell
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        true
    }
    
    func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        true
    }
    
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        
        guard let completedTasks = completedTasks,
              var completedTasksArray = Array(completedTasks) as? [Task],
              let outstandingTasks = outstandingTasks,
              var outstandingTasksArray = Array(outstandingTasks) as? [Task]
        else { return }
        
        if destinationIndexPath.section != sourceIndexPath.section && destinationIndexPath.section == 0 {
            
            let outstandingTask = outstandingTasksArray.remove(at: sourceIndexPath.row)
            
            completedTasksArray.insert(outstandingTask, at: destinationIndexPath.row)
            
            StorageManager.saveTaskWhenYouMoveCellOrPutDoneButton(outstandingTask)
            
        }
        else if destinationIndexPath.section != sourceIndexPath.section && destinationIndexPath.section == 1 {
            
            let completedTask = completedTasksArray.remove(at: sourceIndexPath.row)
            
            outstandingTasksArray.insert(completedTask, at: destinationIndexPath.row)
            StorageManager.saveTaskWhenYouMoveCellOrPutDoneButton(completedTask)
        }
    }
    
    private func filteringTasks() {
        completedTasks = currentTaskList?.tasks.filter("isComplete = true")
        outstandingTasks = currentTaskList?.tasks.filter("isComplete = false")
        tableView.reloadData()
    }
    
    @objc func editTapped(_ sender:UIButton!) {
        tableView.isEditing.toggle()
        self.navigationItem.rightBarButtonItem = tableView.isEditing ? doneBtn : editBtn
        
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let task = indexPath.section == 0 ? completedTasks?[indexPath.row] : outstandingTasks?[indexPath.row]
        guard let task = task else { return nil }
        
        let deleteContextItem = UIContextualAction(style: .destructive, title: "Delete") { _, _, _ in
            StorageManager.deleteTask(task)
            self.filteringTasks()
            
        }
        let editContextItem = UIContextualAction(style: .destructive, title: "Edit") { _, _, _ in
            self.alertForAddAndUpdateList(tasksFlow: .editingNewTask(task: task))
        }
        let doneText = task.isComplete ? "Not done" : "Done"
        let doneContextItem = UIContextualAction(style: .destructive, title: doneText) { _, _, _ in
            StorageManager.saveTaskWhenYouMoveCellOrPutDoneButton(task)
            self.filteringTasks()
        }
        editContextItem.backgroundColor = UIColor(red: 0.41, green: 0.07, blue: 0.85, alpha: 1.00)
        deleteContextItem.backgroundColor = .red
        doneContextItem.backgroundColor = .green
        
        let swipeActions = UISwipeActionsConfiguration(actions: [deleteContextItem, editContextItem, doneContextItem])
        
        return swipeActions
    }
}

extension TasksViewController {
    
    @objc func addTapped(_ sender:UIButton!) {
        alertForAddAndUpdateList(tasksFlow: .addingNewTask)
    }
    
    private func alertForAddAndUpdateList(tasksFlow: TasksFlow ) {
        
        let textForAlert = TextForAlert(tasksFlow: tasksFlow)
        
        let alert = UIAlertController(title: textForAlert.titleForAlert, message: textForAlert.messageForAlert, preferredStyle: .alert)
        
        var taskTextField: UITextField!
        var noteTextField: UITextField!
        
        alert.addTextField { textField in
            taskTextField = textField
            taskTextField.placeholder = textForAlert.newTextFieldPlaceholder
            
            taskTextField.text = textForAlert.taskName
        }
        
        alert.addTextField { textFieldForEditing in
            noteTextField = textFieldForEditing
            noteTextField.placeholder = textForAlert.noteTextFieldPlaceholder
            
            noteTextField.text = textForAlert.taskNote
        }
        
        let saveButtonAction = UIAlertAction(title: textForAlert.doneButtonForAlert, style: .default) { [weak self] _ in
            
            guard let newNameTask = taskTextField.text,
                  !newNameTask.isEmpty,
                  let newNote = noteTextField.text,
                  !newNote.isEmpty,
                  let self = self else { return }
            
            switch tasksFlow {
            case .addingNewTask:
                let task = Task()
                task.name = newNameTask
                task.note = newNote
                guard let currentTaskList = self.currentTaskList else { return }
                StorageManager.saveTask(currentTaskList, task: task)
            case .editingNewTask(let task):
                StorageManager.editTask(task, newNameTask: newNameTask, newNote: newNote)
            }
            self.filteringTasks()
        }
        
        let cancelButtonAction = UIAlertAction(title: textForAlert.cancelText, style: .destructive)
        
        alert.addAction(saveButtonAction)
        alert.addAction(cancelButtonAction)
        
        present(alert, animated: true)
    }
}
