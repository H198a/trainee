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
