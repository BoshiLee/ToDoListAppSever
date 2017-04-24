import Vapor
import HTTP
import VaporSQLite

let drop = Droplet()
try drop.addProvider(VaporSQLite.Provider.self)

let taskController = TasksViewController()
taskController.requestsRouter(by: drop)


drop.run()
