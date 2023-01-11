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
    }

    func setUpCell(name: String, competed: String){
        self.title.font = UIFont.systemFont(ofSize: 20, weight: .medium)
        self.title.textColor = .black
        self.title.numberOfLines = 0
        
        self.numberOfCompletedTasks.font = UIFont.systemFont(ofSize: 20, weight: .medium)
        self.numberOfCompletedTasks.textColor = .black
        self.numberOfCompletedTasks.numberOfLines = 0
        
        self.contentView.addSubview(self.title)
        self.contentView.addSubview(self.numberOfCompletedTasks)

        self.title.translatesAutoresizingMaskIntoConstraints = false
        self.numberOfCompletedTasks.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            self.title.topAnchor.constraint(equalTo: self.contentView.topAnchor, constant: 14),
            self.title.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor, constant: 14),
            self.title.widthAnchor.constraint(equalToConstant: 100),

            self.numberOfCompletedTasks.topAnchor.constraint(equalTo: self.contentView.topAnchor, constant: 14),
            self.numberOfCompletedTasks.leadingAnchor.constraint(equalTo: self.title.trailingAnchor, constant: 14),
            self.numberOfCompletedTasks.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor, constant: -14),
            self.numberOfCompletedTasks.widthAnchor.constraint(equalToConstant: 20)
        ])
        self.title.text = name
        self.numberOfCompletedTasks.text = competed
    }
}
