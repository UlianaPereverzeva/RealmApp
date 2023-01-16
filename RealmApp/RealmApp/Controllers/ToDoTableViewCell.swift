//
//  ToDoTableViewCell.swift
//  RealmApp
//
//  Created by ульяна on 11.01.23.
//

import UIKit

class ToDoTableViewCell: UITableViewCell {

    var title = UILabel()
    var numberOfCompletedTasks = UILabel()
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        if selected == true{
            self.contentView.backgroundColor = UIColor(red: 0.41, green: 0.07, blue: 0.85, alpha: 1.00)
            self.title.textColor = .white
            self.numberOfCompletedTasks.textColor = .white
            } else if selected == false {
                self.contentView.backgroundColor = .clear
                self.title.textColor = .black
                self.numberOfCompletedTasks.textColor = .red
            }
    }

    func setUpCell(with taskList: TasksList){
        self.title.font = UIFont.systemFont(ofSize: 20, weight: .medium)
        self.title.textColor = .black
        self.title.text = taskList.name
        self.title.numberOfLines = 0
        
        let completedTasks = taskList.tasks.filter("isComplete = true")
        let outstandingTasks = taskList.tasks.filter("isComplete = false")
        
        if !outstandingTasks.isEmpty {
            numberOfCompletedTasks.text = "Outstanding tasks: \(outstandingTasks.count)"
            numberOfCompletedTasks.font = UIFont.systemFont(ofSize: 19, weight: .regular)
            numberOfCompletedTasks.textColor = .red
        } else if !completedTasks.isEmpty {
            numberOfCompletedTasks.text = "✓"
            numberOfCompletedTasks.font = UIFont.boldSystemFont(ofSize: 24)
            numberOfCompletedTasks.textColor = .green
        } else {
            numberOfCompletedTasks.text = "0"
            numberOfCompletedTasks.font = UIFont.systemFont(ofSize: 19, weight: .regular)
            numberOfCompletedTasks.textColor = .darkGray
        }

        self.numberOfCompletedTasks.numberOfLines = 0
        self.numberOfCompletedTasks.textAlignment = .right
        
        self.contentView.addSubview(self.title)
        self.contentView.addSubview(self.numberOfCompletedTasks)

        self.title.translatesAutoresizingMaskIntoConstraints = false
        self.numberOfCompletedTasks.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            self.title.topAnchor.constraint(equalTo: self.contentView.topAnchor, constant: 20),
            self.title.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor, constant: 14),
            self.title.widthAnchor.constraint(equalToConstant: 100),
            self.title.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor, constant: -14),


            self.numberOfCompletedTasks.topAnchor.constraint(equalTo: self.contentView.topAnchor, constant: 20),
            self.numberOfCompletedTasks.leadingAnchor.constraint(equalTo: self.title.trailingAnchor, constant: 14),
            self.numberOfCompletedTasks.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor, constant: -14),
            self.numberOfCompletedTasks.widthAnchor.constraint(equalToConstant: 200)
        ])
    
    }
}
