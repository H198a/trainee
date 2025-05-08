import UIKit
import CoreData
import DropDown

class ViewController: UIViewController {
    //MARK: Outlet and Variable Declaration
    @IBOutlet weak var tblTasks: UITableView!
    @IBOutlet weak var lblNoTask: UILabel!
    @IBOutlet weak var lblStatus: UILabel!
    @IBOutlet weak var lblUsers: UILabel!
    @IBOutlet weak var statusView: UIView!
    @IBOutlet weak var usersView: UIView!
    
    let statusDropdown = DropDown()
    let usersDropdown = DropDown()
    
    var selectedStatus: String = "All"//filter for status
    var selectedUser: String = "All"   // filter for assigned user
    
    var arrStatus = ["Done","In Progress","Open","All"]
    var arrUsers: [String] = ["All"]
    
    var tasks: [TaskSection] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUP()
        setupDropdowns()
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
        requestNotificationPermission()
        lblStatus.isUserInteractionEnabled = false
        lblUsers.isUserInteractionEnabled = false
        
        let nibName = UINib(nibName: "TaskCell", bundle: nil)
        tblTasks.register(nibName, forCellReuseIdentifier: "TaskCell")
        tblTasks.sectionHeaderTopPadding = 0//removes top space of section header
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
            
            var openTasks: [TaskSection.Element] = []
            var inProgressTasks: [TaskSection.Element] = []
            var doneTasks: [TaskSection.Element] = []
            var allUsersSet: Set<String> = []
            
            for taskk in taskResults{
                let id = taskk.taskID ?? "0"
                let title = taskk.title ?? "no title"
                let desc = taskk.desc ?? "no desc"
                let endDate = taskk.endDate ?? Date()
                let startDate = taskk.startDate ?? Date()
                let status = taskk.status ?? "no status"
                
                var arrAssignedUsers: [String] = []
                if let userSet = taskk.assigneUsers as? Set<AssignedUsers>{
                    //convert set to array and get back to set
                    arrAssignedUsers = Array(Set(userSet.compactMap {$0.name}))
                    allUsersSet.formUnion(arrAssignedUsers)
                    print("arruserss---drowpdown for assignedusers",arrUsers)
                    print("assignedUsers for task:",title,":",arrAssignedUsers)
                }
                let assignedUsersString = arrAssignedUsers.joined(separator: ",")
                
                let taskTuple = (id: id,title: title, startDate: startDate, endDate: endDate, status: status, desc: desc, assignTo: assignedUsersString)
                
                // filter status and users
                let shouldIncludeTask = (selectedStatus == "All" || selectedStatus.lowercased() == status.lowercased()) &&
                                        (selectedUser == "All" || arrAssignedUsers.contains(selectedUser))
                if shouldIncludeTask{
                    switch status.lowercased() {
                    case "open":
                        if selectedStatus == "All" || selectedStatus.lowercased() == "open" {
                            openTasks.append(taskTuple)
                        }
                    case "in progress":
                        if selectedStatus == "All" || selectedStatus.lowercased() == "in progress" {
                            inProgressTasks.append(taskTuple)
                        }
                    case "done":
                        if selectedStatus == "All" || selectedStatus.lowercased() == "done" {
                            doneTasks.append(taskTuple)
                        }
                    default:
                        print("Unknown status:", status)
                    }
                }
            }
            // Build final sections
            if !openTasks.isEmpty {
                tasks.append(TaskSection(Tasktitle: "Open", tasks: openTasks.sorted(by: { $0.startDate! > $1.startDate! })))
            }
            if !inProgressTasks.isEmpty {
                tasks.append(TaskSection(Tasktitle: "In Progress", tasks: inProgressTasks.sorted(by: { $0.startDate! > $1.startDate! })))
            }
            if !doneTasks.isEmpty {
                tasks.append(TaskSection(Tasktitle: "Done", tasks: doneTasks.sorted(by: { $0.startDate! > $1.startDate! })))
            }
            // Update users dropdown
            var updatedUsers = Array(allUsersSet).sorted()
            updatedUsers.insert("All", at: 0)
            arrUsers = updatedUsers
            usersDropdown.dataSource = arrUsers
            DispatchQueue.main.async{
                self.tblTasks.reloadData()
                self.lblNoTask.isHidden = !self.tasks.isEmpty
            }
        } catch{
            print("Error in fetching tasks-----",error)
        }
    }
    
    func requestNotificationPermission() {
        let center = UNUserNotificationCenter.current()
        center.requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if granted {
                print("Notification permission granted.")
            } else {
                print("Notification permission denied.")
            }
        }
    }
    
    func setupDropdowns(){
        statusDropdown.anchorView = statusView
        statusDropdown.dataSource = arrStatus
        statusDropdown.selectionAction = { (index: Int, item: String) in
            print("selected item:",item,"at index:",index)
//            self.lblStatus.text = self.arrStatus[index]
            print("selected item:", item)
            self.lblStatus.text = item
            self.selectedStatus = item
            self.fetchTasks()
        }
        DropDown.startListeningToKeyboard()
        statusDropdown.bottomOffset = CGPoint(x: 0, y:(statusDropdown.anchorView?.plainView.bounds.height)!)
        // When drop down is displayed with `Direction.top`, it will be above the anchorView
        statusDropdown.topOffset = CGPoint(x: 0, y:-(statusDropdown.anchorView?.plainView.bounds.height)!)
        statusDropdown.direction = .bottom
        statusDropdown.cellHeight = 50
        statusDropdown.backgroundColor = .black
        statusDropdown.textColor = .white
        statusDropdown.layer.cornerRadius = 10
        
        //assignedusers
        usersDropdown.anchorView = usersView
        usersDropdown.selectionAction = { (index: Int, item: String) in
            print("selected item:",item,"at index:",index)
            print("selected item:", item)
            self.lblUsers.text = item
            self.selectedUser = item
            self.fetchTasks()
        }
        DropDown.startListeningToKeyboard()
        usersDropdown.bottomOffset = CGPoint(x: 0, y:(usersDropdown.anchorView?.plainView.bounds.height)!)
        // When drop down is displayed with `Direction.top`, it will be above the anchorView
        usersDropdown.topOffset = CGPoint(x: 0, y:-(usersDropdown.anchorView?.plainView.bounds.height)!)
        usersDropdown.direction = .bottom
        usersDropdown.cellHeight = 50
        usersDropdown.backgroundColor = .black
        usersDropdown.textColor = .white
        usersDropdown.layer.cornerRadius = 10
    }
}
//MARK: UITableViewDataSource, UITableViewDelegate
extension ViewController: UITableViewDataSource, UITableViewDelegate{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tasks[section].tasks.count
    }
     func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        guard let headerView = view as? UITableViewHeaderFooterView else { return }
         headerView.tintColor = .border //use any color you want here .red, .black etc
    }
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return tasks[section].Tasktitle
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        return tasks.count
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TaskCell", for: indexPath) as! TaskCell
        let newTask = tasks[indexPath.section].tasks[indexPath.row]
         cell.lblTitle.text = newTask.title
        cell.lblDesc.text = newTask.desc
         cell.lblStatus.text = newTask.status
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM dd, yyyy"
        cell.lblDate.text = formatter.string(from: newTask.startDate!)
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedUser = tasks[indexPath.section].tasks[indexPath.row]
        print("selectedUser::::::::::::::::",selectedUser)
        let detailVC = storyboard?.instantiateViewController(withIdentifier: "DetailVC") as! DetailVC
        detailVC.titleText = selectedUser.title
        detailVC.startDate = selectedUser.startDate
        detailVC.assignedUsers = selectedUser.assignTo!.components(separatedBy: ",")
        detailVC.endDate = selectedUser.endDate
        detailVC.status = selectedUser.status
        detailVC.descText = selectedUser.desc
        detailVC.ID = selectedUser.id
        
        if let taskID = selectedUser.id {
                guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
                let context = appDelegate.persistentContainer.viewContext
                let request: NSFetchRequest<TaskEntity> = TaskEntity.fetchRequest()
                request.predicate = NSPredicate(format: "taskID == %@", taskID)
                do {
                    let result = try context.fetch(request)
                    if let fullTaskEntity = result.first {
                        detailVC.tasks = fullTaskEntity // ✅ Pass the actual TaskEntity
                    }
                } catch {
                    print("Error fetching TaskEntity for detail:", error)
                }
            }
        
        navigationController?.pushViewController(detailVC, animated: true)
    }
    
    
     func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
          
          // action one
          let editAction = UITableViewRowAction(style: .default, title: "In Progress", handler: { (action, indexPath) in
               print("Edit tapped")
              let taskID = self.tasks[indexPath.section].tasks[indexPath.row].id
               guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else{return}
               let context = appDelegate.persistentContainer.viewContext
               
               let fetchReq: NSFetchRequest<TaskEntity> = TaskEntity.fetchRequest()
               fetchReq.predicate = NSPredicate(format: "taskID == %@", taskID! as CVarArg)
               do{
                    let results = try context.fetch(fetchReq)
                    if let taskToUpdate = results.first {
                         taskToUpdate.status = "In Progress"
                         try context.save()
                         print("Status updated to In Progress")
                         self.fetchTasks()
                    }
               } catch{
                    print("Error updating status: \(error)")
               }
          })
         editAction.backgroundColor = UIColor.systemYellow
          
          // action two
          let deleteAction = UITableViewRowAction(style: .default, title: "Delete") { (action, indexPath) in
              print("Delete tapped")
              let taskID = self.tasks[indexPath.section].tasks[indexPath.row].id
              guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
              let context = appDelegate.persistentContainer.viewContext

              let deleteReq: NSFetchRequest<TaskEntity> = TaskEntity.fetchRequest()
               deleteReq.predicate = NSPredicate(format: "taskID == %@", taskID! as CVarArg)

              let alert = UIAlertController(title: "Delete", message: "Do you want to delete this task?", preferredStyle: .alert)
              alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
              alert.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: { _ in
                  do {
                      let results = try context.fetch(deleteReq)
                      if let taskToDelete = results.first {
                          context.delete(taskToDelete)
                          try context.save()
                          self.fetchTasks()
//                          self.tblTasks.deleteRows(at: [indexPath], with: .none)
                          print("task deleted successfully")
                      }
                  } catch {
                      print("failed to delete task: \(error)")
                  }
              }))

              self.present(alert, animated: true, completion: nil)
          }
          deleteAction.backgroundColor = UIColor.red
         
         // action three
         let doneAction = UITableViewRowAction(style: .default, title: "Done", handler: { (action, indexPath) in
              print("Edit tapped")
             let taskID = self.tasks[indexPath.section].tasks[indexPath.row].id
              guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else{return}
              let context = appDelegate.persistentContainer.viewContext
              
              let fetchReq: NSFetchRequest<TaskEntity> = TaskEntity.fetchRequest()
              fetchReq.predicate = NSPredicate(format: "taskID == %@", taskID! as CVarArg)
              do{
                   let results = try context.fetch(fetchReq)
                   if let taskToUpdate = results.first {
                        taskToUpdate.status = "Done"
                        try context.save()
                        print("Status updated to Done")
                        self.fetchTasks()
                   }
              } catch{
                   print("Error updating status: \(error)")
              }
         })
         doneAction.backgroundColor = UIColor.systemGreen
          return [editAction, deleteAction, doneAction]
     }
}
//MARK: Click Events
extension ViewController{
    @IBAction func onClickAddTasks(_ sender: UIButton) {
        let addtaskVC = storyboard?.instantiateViewController(withIdentifier: "AddTasksVC") as! AddTasksVC
        addtaskVC.isFormEdit = false
        navigationController?.pushViewController(addtaskVC, animated: true)
    }
    @IBAction func onClickUsersDropdown(_ sender: UIControl) {
        print("on click users")
        usersDropdown.show()
    }
    
    @IBAction func onClickStatusDropdown(_ sender: UIControl) {
        print("on click status")
        statusDropdown.show()
    }
}



import UIKit
import CoreData
import IQKeyboardManager

class AddTasksVC: UIViewController {
//MARK: Outlet and Variable Declaration
    @IBOutlet weak var titleView: UIView!
    @IBOutlet weak var descView: UIView!
    @IBOutlet weak var startDateView: UIView!
    @IBOutlet weak var endDateView: UIView!
    @IBOutlet weak var assignView: UIView!
    @IBOutlet weak var txtTitle: UITextField!
    @IBOutlet weak var txtDesc: UITextView!
    @IBOutlet weak var startDate: UIDatePicker!
    @IBOutlet weak var endDate: UIDatePicker!
    @IBOutlet weak var txtAssign: UITextField!
    @IBOutlet weak var cvAssignedUsers: UICollectionView!
    @IBOutlet weak var btnAddAndUpdate: UIButton!
    
    var users: [AssignedUsers] = []
    var tasks: TaskEntity?
    var isFormEdit = false
    
    var titlee: String?
    var desc: String?
    var ussers: [String] = []
    override func viewDidLoad() {
        super.viewDidLoad()
        setUP()
        cvAssignedUsers.reloadData()
    }
    @objc func deleteUser(_ sender: UIButton) {
        let index = sender.tag
        users.remove(at: index)
        cvAssignedUsers.reloadData()
    }
    @objc func didPressOnDontBtn(){
        txtAssign.resignFirstResponder()//removes keyboard on done button click
        addUserFromTextField()
    }
}
//MARK: Setup UI
extension AddTasksVC{
    func setUP(){
    
        let nibName = UINib(nibName: "AddTaskCell", bundle: nil)
        cvAssignedUsers.register(nibName, forCellWithReuseIdentifier: "AddTaskCell")
        
        if isFormEdit {
            if let task = tasks {
                txtTitle.text = task.title
                txtDesc.text = task.desc
                startDate.date = task.startDate ?? Date()
                endDate.date = task.endDate ?? Date()
                
                // Load assigned users
                if let userSet = task.assigneUsers as? Set<AssignedUsers> {
                    users = Array(userSet)
                }
            }
            btnAddAndUpdate.setTitle("Update", for: .normal)
        } else{
            txtDesc.text = "Enter Description"
            txtDesc.textColor = UIColor.lightGray
        }

        
        titleView.layer.shadowColor = UIColor.black.cgColor
        titleView.layer.shadowOpacity = 0.4
        titleView.layer.shadowOffset = CGSize(width: 0, height: 0)
        titleView.layer.shadowRadius = 4
        titleView.layer.masksToBounds = false  // Ensures shadow is visible
        
        descView.layer.shadowColor = UIColor.black.cgColor
        descView.layer.shadowOpacity = 0.4
        descView.layer.shadowOffset = CGSize(width: 0, height: 0)
        descView.layer.shadowRadius = 4
        descView.layer.masksToBounds = false  // Ensures shadow is visible
        
        startDateView.layer.shadowColor = UIColor.black.cgColor
        startDateView.layer.shadowOpacity = 0.4
        startDateView.layer.shadowOffset = CGSize(width: 0, height: 0)
        startDateView.layer.shadowRadius = 4
        startDateView.layer.masksToBounds = false  // Ensures shadow is visible
        
        endDateView.layer.shadowColor = UIColor.black.cgColor
        endDateView.layer.shadowOpacity = 0.4
        endDateView.layer.shadowOffset = CGSize(width: 0, height: 0)
        endDateView.layer.shadowRadius = 4
        endDateView.layer.masksToBounds = false  // Ensures shadow is visible
        
        assignView.layer.shadowColor = UIColor.black.cgColor
        assignView.layer.shadowOpacity = 0.4
        assignView.layer.shadowOffset = CGSize(width: 0, height: 0)
        assignView.layer.shadowRadius = 4
        assignView.layer.masksToBounds = false  // Ensures shadow is visible
        
       
        txtDesc.delegate = self
        
        txtAssign.delegate = self
        
        startDate.minimumDate = Date()
        endDate.minimumDate = Date()
    }
}
//MARK: Custom Functions
extension AddTasksVC{
    func validateFields() -> Bool {
        var isValid = true
        if let number = txtTitle.text, number.isEmpty {
            showAlert(message: "Please enter your title")
            isValid = false
        }
        if let number = txtDesc.text, number.isEmpty {
            showAlert(message: "Please enter Description")
            isValid = false
        }
        return isValid
    }
    func showAlert(message: String) {
        let alertController = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alertController, animated: true, completion: nil)
    }
    func addUserFromTextField() {
        guard let name = txtAssign.text?.trimmingCharacters(in: .whitespacesAndNewlines), !name.isEmpty else { return }

           guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
           let context = appDelegate.persistentContainer.viewContext

           let newUser = AssignedUsers(context: context)
           newUser.name = name
           users.append(newUser)

           txtAssign.text = ""
           cvAssignedUsers.reloadData()
    }
    func fetchUsersFromCoreData() -> [String]{
        guard let appDeletegate = UIApplication.shared.delegate as? AppDelegate else{return []}
        let context = appDeletegate.persistentContainer.viewContext
        let request: NSFetchRequest<AssignedUsers> = AssignedUsers.fetchRequest()
        do{
            let result = try context.fetch(request)
            DispatchQueue.main.async{
                self.cvAssignedUsers.reloadData()
            }
            print("data saved succssfully of assignedusers")
            return result.compactMap { $0.name }
        } catch{
            print("error in fetching data",error)
            return []
        }
    }
    func scheduleNotification(eventName: String, eventDescription: String, eventDate: Date, notificationID: String) {
        let notificationContent = UNMutableNotificationContent()
        notificationContent.title = eventName
        notificationContent.body = eventDescription
        notificationContent.sound = .default
        
        let notificationDate = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: eventDate)
        let trigger = UNCalendarNotificationTrigger(dateMatching: notificationDate, repeats: false)
        
        let request = UNNotificationRequest(identifier: notificationID, content: notificationContent, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                self.showAlert(message: "Failed to schedule notification: \(error.localizedDescription)")
            }
        }
    }
}
//MARK: UITextViewDelegate
extension AddTasksVC: UITextViewDelegate{
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == UIColor.lightGray {
            textView.text = nil
            textView.textColor = UIColor.black
        }
    }
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text == "" {
            textView.text = "Enter Description"
            textView.textColor = UIColor.lightGray
        }
    }
}
//MARK: UICollectionViewDataSource, UICollectionViewDelegate
extension AddTasksVC: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        print("uaers--------",users.count)
        return users.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "AddTaskCell", for: indexPath) as! AddTaskCell
        cell.lblUser.text = users[indexPath.item].name
        cell.btnClose.tag = indexPath.item
        cell.btnClose.addTarget(self, action: #selector(deleteUser), for: .touchUpInside)
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 100, height: 30)
    }
}
//MARK: UITextFieldDelegate
extension AddTasksVC: UITextFieldDelegate{
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        addUserFromTextField()
        view.endEditing(true)
        return true
    }
    func textFieldDidEndEditing(_ textField: UITextField) {
        textField.addDoneOnKeyboard(withTarget: self, action: #selector(didPressOnDontBtn))
    }
    func textFieldDidBeginEditing(_ textField: UITextField) {
        textField.addDoneOnKeyboard(withTarget: self, action: #selector(didPressOnDontBtn))
    }
}
//MARK: Click Events
extension AddTasksVC{
    @IBAction func onClickBack(_ sender: Any) {
        navigationController?.popToRootViewController(animated: true)
    }
    @IBAction func onClickAddTask(_ sender: UIButton) {
        if validateFields(){
           
            if txtDesc.textColor == .lightGray{
                showAlert(message: "Please enter description")
            }
            guard users.count >= 1 else{
                showAlert(message: "please assign users")
                return
            }
            guard let titlee = txtTitle.text, !titlee.isEmpty else{
                print("error in title")
                return
            }
            guard let desc = txtDesc.text, !desc.isEmpty else{
                print("error in desc")
                return
            }
            let assign = users.count
            let id = "\(Int.random(in: 1000...9999))"
            let startDate = startDate.date
            let endDate = endDate.date
            
            guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else{
                return
            }
            let context = appDelegate.persistentContainer.viewContext
            let newTask = ToDoApp.TaskEntity(context: context)
            if isFormEdit{
                guard let taskToUpdate = tasks else { return }
                   taskToUpdate.title = txtTitle.text
                   taskToUpdate.desc = txtDesc.text
                   taskToUpdate.endDate = endDate
                   taskToUpdate.startDate = startDate
                   taskToUpdate.assignTo = "\(users.count)"
                   taskToUpdate.status = "Open"
                   
                 

                   do {
                       try context.save()
                       navigationController?.popToRootViewController(animated: true)
                       showAlert(message: "Task updated successfully")
                       print("Task updated successfully:", taskToUpdate)
                       scheduleNotification(eventName: taskToUpdate.title ?? "", eventDescription: taskToUpdate.desc ?? "", eventDate: taskToUpdate.endDate ?? Date(), notificationID: taskToUpdate.taskID ?? "")
//                       users = []
                       cvAssignedUsers.reloadData()
                   } catch {
                       print("Failed to update task:", error)
                       showAlert(message: "Failed to update task.")
                   }
            } else{
                newTask.title = titlee
                newTask.desc = desc
                newTask.assignTo = "\(assign)"
                newTask.startDate = startDate
                newTask.endDate = endDate
                newTask.taskID = id
                newTask.status = "Open"
                
                //Link assigned users to this taskEntity
                for user in users {
                    user.taskEntity = newTask
                }
                do{
                    try context.save()
                    self.dismiss(animated: true)
                    navigationController?.popToRootViewController(animated: true)
                    showAlert(message: "Task added successfully")
                    print("task added successfully",newTask)
//                    users = []
                    scheduleNotification(eventName: newTask.title!, eventDescription: newTask.desc!, eventDate: newTask.endDate!, notificationID: newTask.taskID!)
                    cvAssignedUsers.reloadData()
                } catch{
                    print("failed to add task:----",error)
                }
            }
          
        }
    }
}



import UIKit
import CoreData

class DetailVC: UIViewController {
//MARK: Outlet and Variable Declaration
    @IBOutlet weak var cvAssignedUsers: UICollectionView!    
    @IBOutlet weak var lblDesc: UILabel!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblStatus: UILabel!
    @IBOutlet weak var lblEndDate: UILabel!
    @IBOutlet weak var lblStartDate: UILabel!
    @IBOutlet weak var lblID: UILabel!
 
    var tasks: TaskEntity?
    
    var titleText: String?
    var descText: String?
    var endDate: Date?
    var startDate: Date?
    var status: String?
    var ID: String?
    var assignedUsers: [String] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        setUP()
    }
}
//MARK: SetUp UI
extension DetailVC{
    func setUP(){
        let nibName = UINib(nibName: "DetailCell", bundle: nil)
        cvAssignedUsers.register(nibName, forCellWithReuseIdentifier: "DetailCell")
        cvAssignedUsers.reloadData()
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM dd, yyyy"
        lblEndDate.text = formatter.string(from: endDate!)
        lblStartDate.text = formatter.string(from: startDate!)
        lblTitle.text = titleText
        lblDesc.text = descText
        lblID.text = ID
        lblStatus.text = status
    }
}
//MARK: Custom Functions
extension DetailVC{
    func deleteData(){
        lblID.text = ""
        lblDesc.text = ""
        lblTitle.text = ""
        lblStatus.text = ""
        lblStartDate.text = ""
        lblEndDate.text = ""
        assignedUsers = [""]
    }
}
//MARK: UICollectionViewDataSource, UICollectionViewDelegate
extension DetailVC: UICollectionViewDataSource, UICollectionViewDelegate{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        print("assigned users count--------",assignedUsers.count)
        return assignedUsers.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "DetailCell", for: indexPath) as! DetailCell
        cell.lblName.text = assignedUsers[indexPath.row]
        return cell
    }
}
//MARK: Click Events
extension DetailVC{
    @IBAction func onClickBack(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    @IBAction func onClickUpdate(_ sender: Any) {
        let updateVC = storyboard?.instantiateViewController(withIdentifier: "AddTasksVC") as! AddTasksVC
        updateVC.isFormEdit = true
        updateVC.tasks = tasks
        updateVC.titlee = titleText
        updateVC.desc = descText
        updateVC.ussers = assignedUsers
        navigationController?.pushViewController(updateVC, animated: true)
    }
    @IBAction func onClickDone(_ sender: Any) {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else{return}
        let context = appDelegate.persistentContainer.viewContext
        let taskID = ID
        
        let fetchReq: NSFetchRequest<TaskEntity> = TaskEntity.fetchRequest()
        fetchReq.predicate = NSPredicate(format: "taskID == %@", taskID! as CVarArg)
        do{
            let results = try context.fetch(fetchReq)
            if let taskToUpdate = results.first {
                taskToUpdate.status = "Done"
                lblStatus.text = "Done"
                try context.save()
                print("Status updated to Done")
            }
        } catch{
            print("Error updating status: \(error)")
        }
    }
    
    @IBAction func onClickInProgress(_ sender: Any) {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else{return}
        let context = appDelegate.persistentContainer.viewContext
        let taskID = ID
        
        let fetchReq: NSFetchRequest<TaskEntity> = TaskEntity.fetchRequest()
        fetchReq.predicate = NSPredicate(format: "taskID == %@", taskID! as CVarArg)
        do{
            let results = try context.fetch(fetchReq)
            if let taskToUpdate = results.first {
                taskToUpdate.status = "In Progress"
                lblStatus.text = "In Progress"
                try context.save()
                print("Status updated to In Progress")
            }
        } catch{
            print("Error updating status: \(error)")
        }
    }

    @IBAction func onClickDelete(_ sender: Any) {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        let context = appDelegate.persistentContainer.viewContext
        let taskID = ID
        
        let deleteReq: NSFetchRequest<TaskEntity> = TaskEntity.fetchRequest()
        deleteReq.predicate = NSPredicate(format: "taskID == %@", taskID! as CVarArg)
        
        let alert = UIAlertController(title: "Delete", message: "Do you want to delete this task?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: { _ in
            do {
                let results = try context.fetch(deleteReq)
                if let taskToDelete = results.first {
                    context.delete(taskToDelete)
                    try context.save()
                    self.deleteData()
                    self.cvAssignedUsers.reloadData()
                    print("task deleted successfully")
                }
            } catch {
                print("failed to delete task: \(error)")
            }
        }))
        
        self.present(alert, animated: true, completion: nil)
    }
}



func scheduleNotification(eventName: String, eventDescription: String, eventDate: Date, notificationID: String) {
    let notificationContent = UNMutableNotificationContent()
    notificationContent.title = eventName
    notificationContent.body = eventDescription
    notificationContent.sound = .default

    // Force 9:00 AM time on the end date
    var calendar = Calendar.current
    calendar.timeZone = TimeZone.current

    var notificationDate = calendar.dateComponents([.year, .month, .day], from: eventDate)
    notificationDate.hour = 9
    notificationDate.minute = 0

    let trigger = UNCalendarNotificationTrigger(dateMatching: notificationDate, repeats: false)

    // Remove existing notification with the same ID (update scenario)
    UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [notificationID])

    let request = UNNotificationRequest(identifier: notificationID, content: notificationContent, trigger: trigger)

    UNUserNotificationCenter.current().add(request) { error in
        if let error = error {
            self.showAlert(message: "Failed to schedule notification: \(error.localizedDescription)")
        }
    }
}


if isFormEdit {
    guard let taskToUpdate = tasks else { return }

    taskToUpdate.title = txtTitle.text
    taskToUpdate.desc = txtDesc.text
    taskToUpdate.endDate = endDate
    taskToUpdate.startDate = startDate
    taskToUpdate.assignTo = "\(users.count)"
    taskToUpdate.status = "Open"
    
    // Ensure this stays the same across updates
    let taskID = taskToUpdate.taskID ?? UUID().uuidString
    taskToUpdate.taskID = taskID

    do {
        try context.save()
        scheduleNotification(
            eventName: taskToUpdate.title ?? "",
            eventDescription: taskToUpdate.desc ?? "",
            eventDate: taskToUpdate.endDate ?? Date(),
            notificationID: taskID
        )
        navigationController?.popToRootViewController(animated: true)
        showAlert(message: "Task updated successfully")
    } catch {
        print("Failed to update task:", error)
        showAlert(message: "Failed to update task.")
    }
}
