import UIKit
import CoreImage

class ViewController: UIViewController {

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var collectionView: UICollectionView!

    let context = CIContext()
    var originalImage: UIImage?
    let filterNames = ["Original", "CIPhotoEffectNoir", "CIPhotoEffectChrome", "CIPhotoEffectInstant", "CIPhotoEffectFade", "CIPhotoEffectMono", "CIPhotoEffectProcess"]

    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.dataSource = self
        collectionView.delegate = self

        originalImage = imageView.image
    }

    func applyFilter(_ filterName: String) {
        guard let originalImage = originalImage else { return }

        if filterName == "Original" {
            imageView.image = originalImage
            return
        }

        guard let ciImage = CIImage(image: originalImage),
              let filter = CIFilter(name: filterName) else { return }

        filter.setValue(ciImage, forKey: kCIInputImageKey)

        if let outputImage = filter.outputImage,
           let cgImage = context.createCGImage(outputImage, from: outputImage.extent) {
            imageView.image = UIImage(cgImage: cgImage)
        }
    }
}

extension ViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return filterNames.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "FilterCell", for: indexPath) as! FilterCell

        let filterName = filterNames[indexPath.item]
        cell.filterLabel.text = filterName.replacingOccurrences(of: "CIPhotoEffect", with: "")

        // Show preview of filtered image
        if let image = originalImage {
            if filterName == "Original" {
                cell.filterImageView.image = image
            } else {
                let ciImage = CIImage(image: image)
                let filter = CIFilter(name: filterName)
                filter?.setValue(ciImage, forKey: kCIInputImageKey)

                if let outputImage = filter?.outputImage,
                   let cgImage = context.createCGImage(outputImage, from: outputImage.extent) {
                    cell.filterImageView.image = UIImage(cgImage: cgImage)
                }
            }
        }

        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let selectedFilter = filterNames[indexPath.item]
        applyFilter(selectedFilter)
    }

    // Optional: cell size
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 80, height: 100)
    }
}
func getProductData(){
     SwiftLoader.show(title: "Loading...", animated: true)
     let url = APIUrls.productBaseUrl
//        AF.request("https://api.restful-api.dev/objects").response{ response in
//            if let data = response.data{
//                do{
//                    let userResponse = try JSONDecoder().decode([Product].self, from: data)
//                    self.arrProducts.append(contentsOf: userResponse)
//                    DispatchQueue.main.async{
//                        SwiftLoader.hide()
//                        self.productVc?.cvProduct.reloadData()
//                    }
//                } catch let err{
//                    print("error----------------------------",err.localizedDescription)
//                }
//            }
//        }
 App Transport Security Settings
     APIManager.shared.request(url: url, method: .get) { response in
         switch response{
         case .success(let result):
             self.arrProducts.append(result as! Product)
             DispatchQueue.main.async{
                 SwiftLoader.hide()
                 self.productVc?.cvProduct.reloadData()
             }
         case .failure(let err):
             print("err-----------",err)
         }
     }
 }
 err----------- sessionTaskFailed(error: Error Domain=NSURLErrorDomain Code=-1200 "An SSL error has occurred and a secure connection to the server cannot be made." UserInfo={NSErrorFailingURLStringKey=https://api.restful-api.dev/objects, 
     NSLocalizedRecoverySuggestion=Would you like to connect to the server anyway?, _kCFStreamErrorDomainKey=3, _NSURLErrorFailingURLSessionTaskErrorKey=LocalDataTask <1885EC08-2C9A-44C9-A02E-42402181C664>.<1>, _NSURLErrorRelatedURLSessionTaskErrorKey=(
     "LocalDataTask <1885EC08-2C9A-44C9-A02E-42402181C664>.<1>"
 ), NSLocalizedDescription=An SSL error has occurred and a secure connectio
    n to the server cannot be made., NSErrorFailingURLKey=https://api.restful-api.dev/objects, NSUnderlyingError=0x600000dd7120 {Error Domain=kCFErrorDomainCFNetwork Code=-1200 "(null)" 
    UserInfo={_kCFStreamPropertySSLClientCertificateState=0, _kCFNetworkCFStreamSSLErrorOriginalValue=-9860, _kCFStreamErrorDomainKey=3, _kCFStreamErrorCodeKey=-9860, _NSURLErrorNWPathKey=satisfied (Path is satisfied), interface: en0}}, _kCFStreamErrorCodeKey=-9860})
*/





func getProductData() {
    SwiftLoader.show(title: "Loading...", animated: true)
    let url = APIUrls.productBaseUrl
    
    APIManager.shared.request(url: url, method: .get) { response in
        switch response {
        case .success(let result):
            if let productList = result as? [Product] {
                self.arrProducts.append(contentsOf: productList)
                DispatchQueue.main.async {
                    SwiftLoader.hide()
                    self.productVc?.cvProduct.reloadData()
                }
            } else {
                print("Failed to cast result as [Product]")
                SwiftLoader.hide()
            }
        case .failure(let err):
            print("err-----------", err)
            SwiftLoader.hide()
        }
    }
}


func request(url: String, method: HTTPMethod, completion: @escaping (Result<Any, Error>) -> Void) {
    AF.request(url, method: method).responseData { response in
        switch response.result {
        case .success(let data):
            do {
                let decodedData = try JSONDecoder().decode([Product].self, from: data)
                completion(.success(decodedData))
            } catch {
                completion(.failure(error))
            }
        case .failure(let error):
            completion(.failure(error))
        }
    }
}


 func getProductData() {
     SwiftLoader.show(title: "Loading...", animated: true)
     let url = APIUrls.productBaseUrl
     
     APIManager.shared.request(url: url, method: .get) { response in
         switch response {
         case .success(let result):
             if let productList = result as? [Product] {
                 self.arrProducts.append(contentsOf: productList)
                 DispatchQueue.main.async {
                     SwiftLoader.hide()
                     self.productVc?.cvProduct.reloadData()
                 }
             } else {
                 print("Failed to cast result as [Product]")
                 SwiftLoader.hide()
             }
         case .failure(let err):
             print("err-----------", err)
             SwiftLoader.hide()
         }
     }
 }
 func request(
     url: String,
     method: HTTPMethod,
     parameters: [String: Any]? = nil,
     headers: HTTPHeaders? = nil,
     completion: @escaping (Result<Any, Error>) -> Void
 ){
     AF.request(url,
                method: method,
                parameters: parameters,
                encoding: method == .get ? URLEncoding.default : JSONEncoding.default,
                headers: headers
     ).responseJSON { response in
         switch response.result {
         case .success(let value):
             completion(.success(value))
         case .failure(let error):
             completion(.failure(error))
         }
     }
 }
}



func getProductData() {
    SwiftLoader.show(title: "Loading...", animated: true)
    let url = APIUrls.productBaseUrl

    APIManager.shared.request(url: url, method: .get) { response in
        switch response {
        case .success(let data):
            do {
                let productList = try JSONDecoder().decode([Product].self, from: data)
                self.arrProducts.append(contentsOf: productList)
                DispatchQueue.main.async {
                    SwiftLoader.hide()
                    self.productVc?.cvProduct.reloadData()
                }
            } catch {
                print("Decoding error:", error)
                SwiftLoader.hide()
            }
        case .failure(let err):
            print("Request error:", err)
            SwiftLoader.hide()
        }
    }
}







--------------------
 
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
     
     var users: [AssignedUsers] = []
     
     override func viewDidLoad() {
         super.viewDidLoad()
         setUP()
         cvAssignedUsers.reloadData()
     }
     @objc func deleteUser(_ sender: UIButton) {
         let index = sender.tag
         let nameToDelete = users[index]
 //        deleteUserFromCoreData(name: nameToDelete)
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
         
         txtDesc.text = "Enter Description"
         txtDesc.textColor = UIColor.lightGray
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
 //    func saveUserToCoreData(name: String){
 //        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else{return}
 //        let context = appDelegate.persistentContainer.viewContext
 //        let newUser = ToDoApp.AssignedUsers(context: context)
 //        newUser.name = name
 //        do{
 //            try context.save()
 //            print("data saved successfully...")
 //        } catch{
 //            print("erro in saving data", error)
 //        }
 //    }
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
 //    func deleteUserFromCoreData(name: String){
 //        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else{return}
 //        let context = appDelegate.persistentContainer.viewContext
 //        let deletereq: NSFetchRequest<AssignedUsers> = AssignedUsers.fetchRequest()
 //        deletereq.predicate = NSPredicate(format: "name == %@", name)
 //        do{
 //            let deleteUser = try context.fetch(deletereq)
 //            for userss in deleteUser{
 //               context.delete(userss)
 //            }
 //            try context.save()
 //            print("user deleted successfully")
 //        } catch{
 //            print("cant delete user",error)
 //        }
 //    }
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
 //        let name = users[indexPath.item]
 //        let size = (name as String).size(withAttributes: [.font: UIFont.systemFont(ofSize: 15)])
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
         navigationController?.popViewController(animated: true)
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
                 navigationController?.popViewController(animated: true)
                 showAlert(message: "Task added successfully")
                 print("task added successfully",newTask)
                 users = []
                 cvAssignedUsers.reloadData()
             } catch{
                 print("failed to add task:----",error)
             }
         }
     }
 }

 
 import UIKit

 class DetailVC: UIViewController {
 //MARK: Outlet and Variable Declaration
     @IBOutlet weak var cvAssignedUsers: UICollectionView!
     @IBOutlet weak var lblDesc: UILabel!
     @IBOutlet weak var lblTitle: UILabel!
     @IBOutlet weak var lblStatus: UILabel!
     @IBOutlet weak var lblEndDate: UILabel!
     @IBOutlet weak var lblStartDate: UILabel!
     @IBOutlet weak var lblID: UILabel!
     
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
         let formatter = DateFormatter()
         formatter.dateFormat = "MMM dd, yyyy"
         lblEndDate.text = formatter.string(from: endDate!)
         lblStartDate.text = formatter.string(from: startDate!)
         lblTitle.text = titleText
         lblDesc.text = descText
         lblID.text = ID
         lblStatus.text = status
 //                cvAssignedUsers.reloadData()
     }
 }
 //MARK: UICollectionViewDataSource, UICollectionViewDelegate
 extension DetailVC: UICollectionViewDataSource, UICollectionViewDelegate{
     func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
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
 }
 import UIKit
 import CoreData

 class ViewController: UIViewController {
     //MARK: Outlet and Variable Declaration
     @IBOutlet weak var tblTasks: UITableView!
     @IBOutlet weak var lblNoTask: UILabel!

     let arrHeaders = ["Open","In Progress","Done"]
     var tasks: [TaskSection] = []
     
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
             
             for taskk in taskResults{
                  let id = taskk.taskID ?? "0"
                 let title = taskk.title ?? "no title"
                 let desc = taskk.desc ?? "no desc"
                 let endDate = taskk.endDate ?? Date()
                 let startDate = taskk.startDate ?? Date()
                 let status = taskk.status ?? "no status"
 //                let assign = taskk.assignTo ?? "no user assigned"
                 var arrAssignedUsers: [String] = []
                 if let userSet = taskk.assigneUsers as? Set<AssignedUsers>{
                     //convert set to array and get back to set
                     arrAssignedUsers = Array(Set(userSet.compactMap {$0.name}))
                     print("assignedUsers for task:",title,":",arrAssignedUsers)
                 }
                 let assignedUsersString = arrAssignedUsers.joined(separator: ",")
                  let taskTuple = (id: id,title: title, startDate: startDate, endDate: endDate, status: status, desc: desc, assignTo: assignedUsersString)
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
             //only display those headers which has data
             if !openTasks.isEmpty{
                 tasks.append(TaskSection(Tasktitle: "Open", tasks: openTasks.sorted(by: {$0.startDate! > $1.startDate!})))
             }
             if !inProgressTasks.isEmpty{
                 tasks.append(TaskSection(Tasktitle: "In Progress", tasks: inProgressTasks.sorted(by: {$0.startDate! > $1.startDate!})))
             }
             if !doneTasks.isEmpty{
                 tasks.append(TaskSection(Tasktitle: "Done", tasks: doneTasks.sorted(by: {$0.startDate! > $1.startDate!})))
             }
 //            tasks.sort { $0.startDate > $1.startDate }
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
           editAction.backgroundColor = UIColor.blue
           
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
         navigationController?.pushViewController(addtaskVC, animated: true)
     }
 }

 /*
  import UIKit
  import CoreData

  class ViewController: UIViewController {
      //MARK: Outlet and Variable Declaration
      @IBOutlet weak var tblTasks: UITableView!
      @IBOutlet weak var lblNoTask: UILabel!

  //     var tasks: [(id: String?,title: String, startDate: Date, endDate: Date, status: String, desc: String, assignTo: String)] = []
      var tasks: [[(id: String?, title: String, startDate: Date, endDate: Date, status: String, desc: String, assignTo: String)]] = [[], [], []]
      let arrHeaders = ["Open","In Progress","Done"]
  //    var spaceBetweenSections = 100.0
      
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
          tblTasks.sectionHeaderTopPadding = 0//removes top space of section header
      }
  }
  //MARK: Custom Functions
  extension ViewController{
      func fetchTasks(){
          lblNoTask.isHidden = true
          guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else{return}
          let context = appDelegate.persistentContainer.viewContext
          
          tasks = [[], [], []]
          
          let tasksFetch: NSFetchRequest<TaskEntity> = TaskEntity.fetchRequest()
          do{
              let taskResults = try context.fetch(tasksFetch)
              
              for taskk in taskResults{
                   let id = taskk.taskID ?? "0"
                  let title = taskk.title ?? "no title"
                  let desc = taskk.desc ?? "no desc"
                  let endDate = taskk.endDate ?? Date()
                  let startDate = taskk.startDate ?? Date()
                  let status = taskk.status ?? "no status"
  //                let assign = taskk.assignTo ?? "no user assigned"
                  var arrAssignedUsers: [String] = []
                  if let userSet = taskk.assigneUsers as? Set<AssignedUsers>{
                      //convert set to array and get back to set
                      arrAssignedUsers = Array(Set(userSet.compactMap {$0.name}))
                      print("assignedUsers for task:",title,":",arrAssignedUsers)
                  }
                  let assignedUsersString = arrAssignedUsers.joined(separator: ",")
                   let taskTuple = (id: id,title: title, startDate: startDate, endDate: endDate, status: status, desc: desc, assignTo: assignedUsersString)
                  switch status.lowercased() {
                  case "open":
                      tasks[0].append(taskTuple)
                  case "in progress":
                      tasks[1].append(taskTuple)
                  case "done":
                      tasks[2].append(taskTuple)
                  default:
                      print("Unknown status:", status)
                  }
              }
              for i in 0..<tasks.count {
                  tasks[i].sort { $0.startDate > $1.startDate }
              }
  //            tasks.sort { $0.startDate > $1.startDate }
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
          return tasks[section].count
      }
       func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
          guard let headerView = view as? UITableViewHeaderFooterView else { return }
           headerView.tintColor = .border //use any color you want here .red, .black etc
      }
      func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
          if section < arrHeaders.count{
              return arrHeaders[section]
          }
          return nil
      }
      func numberOfSections(in tableView: UITableView) -> Int {
          return tasks.count
      }
      func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
          return 40
      }
      func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
          let cell = tableView.dequeueReusableCell(withIdentifier: "TaskCell", for: indexPath) as! TaskCell
          let newTask = tasks[indexPath.section][indexPath.row]
           cell.lblTitle.text = newTask.title
          cell.lblDesc.text = newTask.desc
           cell.lblStatus.text = newTask.status
          let formatter = DateFormatter()
          formatter.dateFormat = "MMM dd, yyyy"
          cell.lblDate.text = formatter.string(from: newTask.startDate)
          return cell
      }
      func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
          let selectedUser = tasks[indexPath.section][indexPath.row]
          print("selectedUser::::::::::::::::",selectedUser)
          let detailVC = storyboard?.instantiateViewController(withIdentifier: "DetailVC") as! DetailVC
          detailVC.titleText = selectedUser.title
          detailVC.startDate = selectedUser.startDate
          detailVC.assignedUsers = selectedUser.assignTo.components(separatedBy: ",")
          detailVC.endDate = selectedUser.endDate
          detailVC.status = selectedUser.status
          detailVC.descText = selectedUser.desc
          detailVC.ID = selectedUser.id
          
          navigationController?.pushViewController(detailVC, animated: true)
      }
       func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
            
            // action one
            let editAction = UITableViewRowAction(style: .default, title: "In Progress", handler: { (action, indexPath) in
                 print("Edit tapped")
                let taskID = self.tasks[indexPath.section][indexPath.row].id
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
            editAction.backgroundColor = UIColor.blue
            
            // action two
            let deleteAction = UITableViewRowAction(style: .default, title: "Delete") { (action, indexPath) in
                print("Delete tapped")
                let taskID = self.tasks[indexPath.section][indexPath.row].id
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
                            self.tblTasks.deleteRows(at: [indexPath], with: .none)
                            print("task deleted successfully")
                        }
                    } catch {
                        print("failed to delete task: \(error)")
                    }
                }))

                self.present(alert, animated: true, completion: nil)
            }
            deleteAction.backgroundColor = UIColor.red
           
           let doneAction = UITableViewRowAction(style: .default, title: "Done", handler: { (action, indexPath) in
                print("Edit tapped")
               let taskID = self.tasks[indexPath.section][indexPath.row].id
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
          navigationController?.pushViewController(addtaskVC, animated: true)
      }
  }

 */
 import Foundation
 struct TaskSection{
     typealias Element = (id: String?, title: String?, startDate: Date?, endDate: Date?, status: String?, desc: String?, assignTo: String?)
         
         let Tasktitle: String
         var tasks: [Element]
 }
