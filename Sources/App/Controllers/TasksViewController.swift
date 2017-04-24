//
//  TasksViewController.swift
//  ToDoList
//
//  Created by Boshi Li on 04/04/2017.
//
//
import Vapor
import VaporSQLite
import Foundation
import HTTP

struct Task: NodeRepresentable {
    let taskID:Int
    let title:String
    
    func makeNode(context: Context) throws -> Node {
        return try Node(node: ["taskID": self.taskID, "title": self.title])
    }
}

extension Task {
    init?(node: Node) {
        guard let taskID = node["taskID"]?.int,
            let title = node["title"]?.string else {
                return nil
        }
        self.init(taskID: taskID, title: title)
    }
}


class TasksViewController {
    func requestsRouter(by drop: Droplet) {
        drop.get("tasks", "all", handler: self.fetchAllTasks)
        drop.post("tasks", "create", handler: self.createTask)
        drop.delete("tasks", "delete", handler: self.deleteTask)
        drop.post("tasks", "update", handler:self.updateTask)
    }
    
    func updateTask(request: Request) throws -> ResponseRepresentable {
        
        guard let updatingTaskID = request.data["taskID"]?.int else {
            throw Abort.badRequest
        }
        
        guard let updatingTaskTitle = request.data["title"]?.string else {
            throw Abort.badRequest
        }
        do {
            try drop.database?.driver.raw("UPDATE Tasks SET title = ? WHERE taskID= ?", [updatingTaskTitle, updatingTaskID])
        } catch {
            print("update fialed")
        }
        return try JSON(node: ["success": true, "data":"\(updatingTaskTitle)"])
        
    }
    
    func createTask(request: Request) throws -> ResponseRepresentable {
        guard let title = request.data["title"]?.string else {
            throw Abort.badRequest
        }
        try drop.database?.driver.raw("INSERT INTO Tasks(title) VALUES(?)", [title])
        
        return try JSON(node: ["success": true, "data":"\(title)"])
    }
    
    func deleteTask(request: Request) throws -> ResponseRepresentable {
        guard let targerID = request.data["taskID"]?.int else {
            throw Abort.badRequest
        }
        
        let beingDeletedTitle = try drop.database?.driver.raw("SELECT taskID, title FROM Tasks WHERE taskID=?", [targerID])
        
        try drop.database?.driver.raw("DELETE FROM Tasks WHERE taskID = ?", [targerID])
        
        return try JSON(node: ["success": true, "data":"\(beingDeletedTitle!)"])
    }
    
    func fetchAllTasks(reqest: Request) throws -> ResponseRepresentable {
        let result = try drop.database?.driver.raw("SELECT taskID, title FROM Tasks;")
        
        guard let nodes = result?.nodeArray else {
            return try JSON(node: [])
        }
        let tasks = nodes.flatMap(Task.init)
        return try JSON(node: tasks)
    }
}
