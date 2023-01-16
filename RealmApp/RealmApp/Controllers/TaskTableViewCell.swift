//
//  TaskTableViewCell.swift
//  RealmApp
//
//  Created by ульяна on 14.01.23.
//

import UIKit

class TaskTableViewCell: UITableViewCell {

    var name = UILabel()
    var note = UILabel()
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        if selected == true{
            self.contentView.backgroundColor = UIColor(red: 0.41, green: 0.07, blue: 0.85, alpha: 1.00)
            } else if selected == false {
                self.contentView.backgroundColor = .clear
            }
    }
    
    func setUpCell(name: String, note: String){
        self.name.font = UIFont.systemFont(ofSize: 20, weight: .medium)
        self.name.textColor = .black
        self.name.numberOfLines = 0
        
        self.note.font = UIFont.systemFont(ofSize: 18, weight: .regular)
        self.note.textColor = .darkGray
        self.note.numberOfLines = 0
        
        self.contentView.addSubview(self.name)
        self.contentView.addSubview(self.note)

        self.name.translatesAutoresizingMaskIntoConstraints = false
        self.note.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            self.name.topAnchor.constraint(equalTo: self.contentView.topAnchor, constant: 20),
            self.name.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor, constant: 14),
            self.name.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor, constant: -14),

            self.note.topAnchor.constraint(equalTo: self.name.bottomAnchor, constant: 6),
            self.note.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor, constant: 14),
            self.note.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor, constant: -14),
            self.note.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor, constant: -14)
        ])
        self.name.text = name
        self.note.text = note
    }
}
