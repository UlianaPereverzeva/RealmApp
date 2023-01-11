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
}
