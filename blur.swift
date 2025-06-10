import UIKit

class ViewController: UIViewController {
    @IBOutlet weak var bottomView: UIView!
    var popupVC: PopupVC? = nil
    var blurView: UIVisualEffectView? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }

    @IBAction func onClickOpn(_ sender: Any) {
        if popupVC == nil {
                   print("Opening popup")

                   // Blur background
                   let blurEffect = UIBlurEffect(style: .dark)
                   let blur = UIVisualEffectView(effect: blurEffect)
                   blur.frame = view.bounds
                   blur.autoresizingMask = [.flexibleWidth, .flexibleHeight]
                   blur.alpha = 0.5
                   view.addSubview(blur)
                   view.bringSubviewToFront(bottomView)
                   self.blurView = blur

                   // Instantiate and add popup
                   guard let popup = storyboard?.instantiateViewController(withIdentifier: "PopupVC") as? PopupVC else { return }
                   self.popupVC = popup

                   addChild(popup)
                   view.addSubview(popup.view)
                   popup.didMove(toParent: self)
                   popup.view.translatesAutoresizingMaskIntoConstraints = false

                   NSLayoutConstraint.activate([
                       popup.view.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
                       popup.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                       popup.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
                       popup.view.bottomAnchor.constraint(equalTo: bottomView.topAnchor)
                   ])
               } else {
                   print("Closing popup")
                   self.removeFromParent()
                   self.popupVC?.view.removeFromSuperview()
               }
/*
        print("button clickedd")
//        let popupVC = storyboard?.instantiateViewController(withIdentifier: "PopupVC") as! PopupVC
        popupVC?.modalPresentationStyle = .popover
        
        let blurEffect = UIBlurEffect(style: .dark) // .light, .extraLight, .regular also available
//           let blurView = UIVisualEffectView(effect: blurEffect)
           blurView.frame = view.bounds
           blurView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
           blurView.alpha = 0.5 // Adjust for transparency
           blurView.tag = 999 // Use this to remove later if needed
           view.addSubview(blurView)
        view.bringSubviewToFront(bottomView)
        
//        addChild(popupVC)
//        view.addSubview(popupVC.view)
//        popupVC.didMove(toParent: self)
//        popupVC.view.translatesAutoresizingMaskIntoConstraints = false
//        
//        NSLayoutConstraint.activate([
//              popupVC.view.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
//              popupVC.view.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
//              popupVC.view.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
//              popupVC.view.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -100)
//          ])
        self.present(popupVC, animated: true, completion: nil)
 */
    }
    @IBAction func onClickClose(_ sender: Any) {
        self.removeFromParent()
        self.popupVC?.view.removeFromSuperview()
        popupVC = nil
    }
    
}
