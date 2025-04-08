# trainee
ndslwnkfjwewe
import Foundation

 class UserRegistrationData {
     static let shared = UserRegistrationData()

     var name: String?
     var email: String?
     var gender: String?
     var age: String?
     var hobbies: [String] = [] // Your hobbies array

     private init() {}

     func reset() {
         name = nil
         email = nil
         gender = nil
         age = nil
         hobbies = []
     }

     func toDictionary() -> [String: Any] {
         return [
             "name": name ?? "",
             "email": email ?? "",
             "gender": gender ?? "",
             "age": age ?? "",
             "hobbies": hobbies
         ]
     }
 }

 UserRegistrationData.shared.name = nameTextField.text
 UserRegistrationData.shared.email = emailTextField.text
 UserRegistrationData.shared.gender = selectedGender
 UserRegistrationData.shared.age = ageTextField.text
 UserRegistrationData.shared.hobbies = selectedIndexes.map { arrLabel[$0] }
 
 
 import UIKit
 import Firebase

 class SubmitVC: UIViewController {

     override func viewDidLoad() {
         super.viewDidLoad()
     }

     @IBAction func onClickSubmit(_ sender: UIButton) {
         let data = UserRegistrationData.shared.toDictionary()

         let dbRef = Database.database().reference()
         let usersRef = dbRef.child("users").childByAutoId()

         usersRef.setValue(data) { error, _ in
             if let error = error {
                 print("🔥 Error: \(error.localizedDescription)")
                 self.showAlert(title: "Error", message: "Failed to save data.")
             } else {
                 print("✅ Data saved successfully")
                 UserRegistrationData.shared.reset()
                 self.showAlert(title: "Success", message: "Data saved to Firebase.")
             }
         }
     }

     func showAlert(title: String, message: String) {
         let alert = UIAlertController(title: title,
                                       message: message,
                                       preferredStyle: .alert)
         alert.addAction(UIAlertAction(title: "OK",
                                       style: .default))
         self.present(alert, animated: true)
     }
 }



<key>NSLocationWhenInUseUsageDescription</key>
    <string>This app needs your location to work properly.</string>
    <key>NSLocationAlwaysAndWhenInUseUsageDescription</key>
    <string>We need access to your location always for background tracking.</string>


 //let y = pickerView.bounds.midY + (i == 0 ? -rowHeight / 2 : rowHeight / 2)


 override func viewDidLayoutSubviews() {
         super.viewDidLayoutSubviews()
         addHighlightLines()
     }

 @IBAction func onClickAllowLocation(_ sender: Any) {
        LocationManager.shared.requestLocation { [weak self] status in
            DispatchQueue.main.async {
                if status == .authorizedWhenInUse || status == .authorizedAlways {
                    // Permission granted → Navigate to next screen
                    self?.navigationController?.popViewController(animated: false)
                } else {
                    //  Permission not granted → Stay on same screen or show alert
                    let alert = UIAlertController(title: "Permission Denied",
                                                  message: "Please allow location access to continue.",
                                                  preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .default))
                    self?.present(alert, animated: true)
                }
            }
        }
    }

class LocationManager: NSObject, CLLocationManagerDelegate{
    static let shared = LocationManager()
    private var locationManager: CLLocationManager = CLLocationManager()
    private var requestLocationAuthorizationCallBack: ((CLAuthorizationStatus) -> Void)?
    
    public func requestLocation(callback: @escaping (CLAuthorizationStatus) -> Void){
        self.locationManager.delegate = self
        self.requestLocationAuthorizationCallBack = callback
        let currentStatus = CLLocationManager.authorizationStatus()
        guard currentStatus == .notDetermined else { return }
        
        if currentStatus == .notDetermined {
                   locationManager.requestWhenInUseAuthorization()
        } else {
            callback(currentStatus)
        }
    }
    
    // MARK: - CLLocationManagerDelegate
    public func locationManager(_ manager: CLLocationManager,
                                didChangeAuthorization status: CLAuthorizationStatus) {
        self.requestLocationAuthorizationCallBack?(status)
    }
}




