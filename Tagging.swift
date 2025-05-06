bimport UIKit
import CoreData

class ViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UITextFieldDelegate {

    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var collectionView: UICollectionView!

    var users: [String] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        textField.delegate = self
        collectionView.delegate = self
        collectionView.dataSource = self
        users = fetchUsersFromCoreData()
        collectionView.reloadData()
    }

    // Triggered when IQKeyboardManager "Done" is tapped
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        addUserFromTextField()
        return true
    }

    // Optional Add Button
    @IBAction func addUserButtonTapped(_ sender: UIButton) {
        addUserFromTextField()
    }

    func addUserFromTextField() {
        guard let name = textField.text?.trimmingCharacters(in: .whitespacesAndNewlines), !name.isEmpty else { return }
        users.append(name)
        saveUserToCoreData(name: name)
        textField.text = ""
        collectionView.reloadData()
    }

    // MARK: - UICollectionView Data Source

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return users.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "UserTagCell", for: indexPath) as? UserTagCell else {
            return UICollectionViewCell()
        }
        cell.nameLabel.text = users[indexPath.item]
        cell.closeButton.tag = indexPath.item
        cell.closeButton.addTarget(self, action: #selector(deleteUser(_:)), for: .touchUpInside)

        cell.tagView.layer.cornerRadius = 12
        cell.tagView.layer.borderWidth = 1
        cell.tagView.layer.borderColor = UIColor.gray.cgColor
        cell.tagView.backgroundColor = UIColor.systemGray5

        return cell
    }

    // Set size to fit text
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let name = users[indexPath.item]
        let size = (name as NSString).size(withAttributes: [.font: UIFont.systemFont(ofSize: 16)])
        return CGSize(width: size.width + 50, height: 32)
    }

    // Delete user
    @objc func deleteUser(_ sender: UIButton) {
        let index = sender.tag
        let nameToDelete = users[index]
        deleteUserFromCoreData(name: nameToDelete)
        users.remove(at: index)
        collectionView.reloadData()
    }

    // MARK: - Core Data

    func saveUserToCoreData(name: String) {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        let context = appDelegate.persistentContainer.viewContext
        let newUser = UserEntity(context: context)
        newUser.name = name
        do {
            try context.save()
        } catch {
            print("Failed to save: \(error)")
        }
    }

    func fetchUsersFromCoreData() -> [String] {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return [] }
        let context = appDelegate.persistentContainer.viewContext
        let request: NSFetchRequest<UserEntity> = UserEntity.fetchRequest()
        do {
            let result = try context.fetch(request)
            return result.compactMap { $0.name }
        } catch {
            print("Failed to fetch: \(error)")
            return []
        }
    }

    func deleteUserFromCoreData(name: String) {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        let context = appDelegate.persistentContainer.viewContext
        let fetchRequest: NSFetchRequest<UserEntity> = UserEntity.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "name == %@", name)
        do {
            let users = try context.fetch(fetchRequest)
            for user in users {
                context.delete(user)
            }
            try context.save()
        } catch {
            print("Failed to delete: \(error)")
        }
    }
}


import UIKit

class UserTagCell: UICollectionViewCell {
    @IBOutlet weak var tagView: UIView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var closeButton: UIButton!
}


import IQKeyboardManagerSwift

func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: ...) -> Bool {
    IQKeyboardManager.shared.enable = true
    IQKeyboardManager.shared.shouldResignOnTouchOutside = true
    IQKeyboardManager.shared.toolbarDoneBarButtonItemText = "Done"
    return true
}



import UIKit
import CoreData

class ViewController: UIViewController {
    //MARK: Outlet and Variable Declaration
    @IBOutlet weak var tblTasks: UITableView!
    @IBOutlet weak var lblNoTask: UILabel!
    
    var tasks: [(title: String, startDate: Date, endDate: Date, status: String, desc: String, assignTo: String)] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUP()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        fetchTasks()
        navigationController?.setNavigationBarHidden(true, animated: true)
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(true, animated: true)
    }
}
//MARK: Setup UI
extension ViewController{
    func setUP(){
        let nibName = UINib(nibName: "TaskCell", bundle: nil)
        tblTasks.register(nibName, forCellReuseIdentifier: "TaskCell")
    }
}
//MARK: Custom Functions
extension ViewController{
    func fetchTasks(){
        lblNoTask.isHidden = true
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else{return}
        let context = appDelegate.persistentContainer.viewContext
        
        tasks.removeAll()
        
        let tasksFetch: NSFetchRequest<TaskEntity> = TaskEntity.fetchRequest()
        do{
            let taskResults = try context.fetch(tasksFetch)
            
            for taskk in taskResults{
                let title = taskk.title ?? "no title"
                let desc = taskk.desc ?? "no desc"
                let endDate = taskk.endDate ?? Date()
                let startDate = taskk.startDate ?? Date()
                let status = taskk.status ?? "no status"
                let assign = taskk.assignTo ?? "no user assigned"
                
                tasks.append((title: title, startDate: startDate, endDate: endDate, status: status, desc: desc, assignTo: assign))
            }
            tasks.sort { $0.startDate > $1.startDate }
            DispatchQueue.main.async{
                self.tblTasks.reloadData()
            }
        } catch{
            print("Error in fetching tasks-----",error)
        }
    }
}
//MARK: UITableViewDataSource, UITableViewDelegate
extension ViewController: UITableViewDataSource, UITableViewDelegate{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
       return tasks.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TaskCell", for: indexPath) as! TaskCell
        let newTask = tasks[indexPath.row]
        cell.lblTitle.text = newTask.title
        cell.lblDesc.text = newTask.desc
        cell.lblStatus.text = newTask.status
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM dd, yyyy"
        cell.lblDate.text = formatter.string(from: newTask.startDate)
        
        return cell
    }
     func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {

         // action one
         let editAction = UITableViewRowAction(style: .default, title: "In Progress", handler: { (action, indexPath) in
             print("Edit tapped")
         })
         editAction.backgroundColor = UIColor.blue

         // action two
         let deleteAction = UITableViewRowAction(style: .default, title: "Delete", handler: { (action, indexPath) in
             print("Delete tapped")
         })
         deleteAction.backgroundColor = UIColor.red

         return [editAction, deleteAction]
     }
}
//MARK: Click Events
extension ViewController{
    @IBAction func onClickAddTasks(_ sender: UIButton) {
        let addtaskVC = storyboard?.instantiateViewController(withIdentifier: "AddTasksVC") as! AddTasksVC
        navigationController?.pushViewController(addtaskVC, animated: true)
    }
}



func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {

    let inProgressAction = UITableViewRowAction(style: .default, title: "In Progress") { (action, indexPath) in
        let taskID = self.tasks[indexPath.row].id

        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        let context = appDelegate.persistentContainer.viewContext

        let fetchRequest: NSFetchRequest<TaskEntity> = TaskEntity.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %@", taskID as CVarArg)

        do {
            let results = try context.fetch(fetchRequest)
            if let taskToUpdate = results.first {
                taskToUpdate.status = "In Progress"
                try context.save()
                print("Status updated to In Progress")
                self.fetchTasks()
            }
        } catch {
            print("Error updating status: \(error)")
        }
    }
    inProgressAction.backgroundColor = UIColor.blue

    let deleteAction = UITableViewRowAction(style: .default, title: "Delete") { (action, indexPath) in
        let taskID = self.tasks[indexPath.row].id

        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        let context = appDelegate.persistentContainer.viewContext

        let fetchRequest: NSFetchRequest<TaskEntity> = TaskEntity.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %@", taskID as CVarArg)

        do {
            let results = try context.fetch(fetchRequest)
            if let taskToDelete = results.first {
                context.delete(taskToDelete)
                try context.save()
                print("Task deleted")
                self.fetchTasks()
            }
        } catch {
            print("Error deleting task: \(error)")
        }
    }
    deleteAction.backgroundColor = UIColor.red

    return [inProgressAction, deleteAction]
}



let deleteAction = UITableViewRowAction(style: .default, title: "Delete", handler: { (action, indexPath) in
     print("Delete tapped")
      let taskID = self.tasks[indexPath.row].id
      guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else{return}
      let context = appDelegate.persistentContainer.viewContext
      
      let deleteReq: NSFetchRequest<TaskEntity> = TaskEntity.fetchRequest()
      deleteReq.predicate = NSPredicate(format: "taskID == %@", taskID! as CVarArg)
      do{
           let alert = UIAlertController(title: "Delete", message: "Do you want to delete this product?", preferredStyle: .alert)
           alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
           alert.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: { _ in
                let results = try context.fetch(deleteReq)
                if let taskDelete = results.first{
                     context.delete(taskDelete)
                     try context.save()
                     self.fetchTasks()
//                        self.tasks.remove(at: indexPath.row)
                     self.tblTasks.deleteRows(at: [indexPath], with: .none)
                }
           }))
          
           self.present(alert, animated: true, completion: nil)
           print("task delete successfully")
      } catch{
           print("failed to delete task",error)
      }
 })
 deleteAction.backgroundColor = UIColor.red
 
 Invalid conversion from throwing function of type '(UIAlertAction) throws -> Void' to non-throwing function type '(UIAlertAction) -> Void'
