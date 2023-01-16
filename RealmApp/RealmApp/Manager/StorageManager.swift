//
//  StorageManager.swift
//  RealmApp
//
//  Created by ульяна on 11.01.23.
//

import Foundation
import RealmSwift

let realm = try! Realm()

class StorageManager {
    
    static func deleteAll(){
        do {
            try realm.write {
                realm.deleteAll()
            }
        } catch {
            print("deleteAll error: \(error)")
        }
    }
    
    static func deleteList(_ tasksList: TasksList) {
        do {
            try realm.write {
                let tasks = tasksList.tasks
                // последовательно удаляем tasks и tasksList
                realm.delete(tasks)
                realm.delete(tasksList)
            }
        } catch {
            print("deleteList error: \(error)")
        }
    }
    
    static func getAllTasksLists() -> Results<TasksList> {
        realm.objects(TasksList.self)
    }
    
    static func editList(_ taskList: TasksList, newListName: String, completion: @escaping () -> Void) {
        do {
            try realm.write {
                taskList.name = newListName
                completion()
            }
        } catch {
            print("editList error: \(error)")
        }
    }
    
    static func saveTasksList(taskList: TasksList) {
        do {
            try realm.write {
                realm.add(taskList)
            }
        } catch {
            print("saveTasksList error: \(error)")
        }
    }
    
    static func makeAllDone(_ taskList: TasksList) {
        do {
            try realm.write {
                taskList.tasks.setValue(true, forKey: "isComplete")
            }
        } catch {
            print("makeAllDone error: \(error)")
        }
    }
    
    // MARK: - Tasks Methods
    
    static func saveTask(_ tasksList: TasksList, task: Task) {
        try! realm.write {
            tasksList.tasks.append(task)
        }
    }
    
    static func saveTaskWhenYouMoveCellOrPutDoneButton(_ task: Task) {
        try! realm.write {
            task.isComplete.toggle()
            
        }
    }
    
    static func editTask(_ task: Task, newNameTask: String, newNote: String) {
        try! realm.write {
            task.name = newNameTask
            task.note = newNote
        }
    }
    
    static func deleteTask(_ task: Task) {
        try! realm.write {
            realm.delete(task)
        }
    }
}

