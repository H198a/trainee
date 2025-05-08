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
    
    var selectedStatus: String = "All" // filter for status
    var selectedUser: String = "All"   // filter for assigned user
    
    var arrStatus = ["Done", "In Progress", "Open", "All"]
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
extension ViewController {
    func setUP() {
        lblStatus.isUserInteractionEnabled = false
        lblUsers.isUserInteractionEnabled = false
        
        let nibName = UINib(nibName: "TaskCell", bundle: nil)
        tblTasks.register(nibName, forCellReuseIdentifier: "TaskCell")
        tblTasks.sectionHeaderTopPadding = 0
    }
}

//MARK: Custom Functions
extension ViewController {
    func fetchTasks() {
        lblNoTask.isHidden = true
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        let context = appDelegate.persistentContainer.viewContext
        
        tasks.removeAll()
        
        let tasksFetch: NSFetchRequest<TaskEntity> = TaskEntity.fetchRequest()
        do {
            let taskResults = try context.fetch(tasksFetch)
            
            var openTasks: [TaskSection.Element] = []
            var inProgressTasks: [TaskSection.Element] = []
            var doneTasks: [TaskSection.Element] = []
            var allUsersSet: Set<String> = []
            
            for taskk in taskResults {
                let id = taskk.taskID ?? "0"
                let title = taskk.title ?? "no title"
                let desc = taskk.desc ?? "no desc"
                let endDate = taskk.endDate ?? Date()
                let startDate = taskk.startDate ?? Date()
                let status = taskk.status ?? "no status"
                
                var arrAssignedUsers: [String] = []
                if let userSet = taskk.assigneUsers as? Set<AssignedUsers> {
                    arrAssignedUsers = Array(Set(userSet.compactMap { $0.name }))
                    allUsersSet.formUnion(arrAssignedUsers)
                }
                
                let assignedUsersString = arrAssignedUsers.joined(separator: ",")
                let taskTuple = (id: id, title: title, startDate: startDate, endDate: endDate, status: status, desc: desc, assignTo: assignedUsersString)
                
                // Filter logic
                let shouldIncludeTask = (selectedStatus == "All" || selectedStatus.lowercased() == status.lowercased()) &&
                                        (selectedUser == "All" || arrAssignedUsers.contains(selectedUser))
                
                if shouldIncludeTask {
                    switch status.lowercased() {
                    case "open":
                        openTasks.append(taskTuple)
                    case "in progress":
                        inProgressTasks.append(taskTuple)
                    case "done":
                        doneTasks.append(taskTuple)
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
            
            DispatchQueue.main.async {
                self.tblTasks.reloadData()
                self.lblNoTask.isHidden = !self.tasks.isEmpty
            }
        } catch {
            print("Error in fetching tasks:", error)
        }
    }
    
    func setupDropdowns() {
        // Status dropdown
        statusDropdown.anchorView = statusView
        statusDropdown.dataSource = arrStatus
        statusDropdown.selectionAction = { (index: Int, item: String) in
            self.lblStatus.text = item
            self.selectedStatus = item
            self.fetchTasks()
        }
        statusDropdown.bottomOffset = CGPoint(x: 0, y: (statusDropdown.anchorView?.plainView.bounds.height)!)
        statusDropdown.topOffset = CGPoint(x: 0, y: -(statusDropdown.anchorView?.plainView.bounds.height)!)
        statusDropdown.direction = .bottom
        statusDropdown.cellHeight = 50
        statusDropdown.backgroundColor = .black
        statusDropdown.textColor = .white
        statusDropdown.layer.cornerRadius = 10
        
        // Users dropdown
        usersDropdown.anchorView = usersView
        usersDropdown.selectionAction = { (index: Int, item: String) in
            self.lblUsers.text = item
            self.selectedUser = item
            self.fetchTasks()
        }
        usersDropdown.bottomOffset = CGPoint(x: 0, y: (usersDropdown.anchorView?.plainView.bounds.height)!)
        usersDropdown.topOffset = CGPoint(x: 0, y: -(usersDropdown.anchorView?.plainView.bounds.height)!)
        usersDropdown.direction = .bottom
        usersDropdown.cellHeight = 50
        usersDropdown.backgroundColor = .black
        usersDropdown.textColor = .white
        usersDropdown.layer.cornerRadius = 10
    }
}

//MARK: UITableViewDataSource, UITableViewDelegate
extension ViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tasks[section].tasks.count
    }

    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        guard let headerView = view as? UITableViewHeaderFooterView else { return }
        headerView.tintColor = .border
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
}

//MARK: Actions
extension ViewController {
    @IBAction func onClickAddTasks(_ sender: UIButton) {
        let addtaskVC = storyboard?.instantiateViewController(withIdentifier: "AddTasksVC") as! AddTasksVC
        navigationController?.pushViewController(addtaskVC, animated: true)
    }

    @IBAction func onClickUsersDropdown(_ sender: UIControl) {
        usersDropdown.show()
    }

    @IBAction func onClickStatusDropdown(_ sender: UIControl) {
        statusDropdown.show()
    }
}






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
            //            tasks.sort { $0.startDate > $1.startDate }
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
            self.selectedStatus = item
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
}
extension ViewController{
    @IBAction func onClickAddTasks(_ sender: UIButton) {
        let addtaskVC = storyboard?.instantiateViewController(withIdentifier: "AddTasksVC") as! AddTasksVC
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
