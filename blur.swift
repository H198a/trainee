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



import UIKit

class ViewController: UIViewController, UITabBarControllerDelegate {
    var popupVC: PopupVC? = nil
    var blurView: UIVisualEffectView? = nil
    var tabView1: tab1!
    var tabView2: tab2!
    var isSelectionTabVisible = false
    var customTabBarContainer: UIView!
    var customTabBarVC: CustomTabBarController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        self.tabBarController?.tabBar.isHidden = false  // Hide system tab bar
        setUP()
//        setupCustomTabBars()
//               showTab1()
    }
    func setUP(){
        customTabBarVC = CustomTabBarController()
               addChild(customTabBarVC)
               view.addSubview(customTabBarVC.view)
               customTabBarVC.didMove(toParent: self)

               customTabBarVC.delegate = self

               NSLayoutConstraint.activate([
                   customTabBarVC.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                   customTabBarVC.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
                   customTabBarVC.view.bottomAnchor.constraint(equalTo: view.bottomAnchor),
                   customTabBarVC.view.heightAnchor.constraint(equalToConstant: 80)
               ])
    }
    @IBAction func onClickSelectAll(_ sender: Any) {
        isSelectionTabVisible.toggle()
//                if isSelectionTabVisible {
//                    showTab2()
//                } else {
//                    showTab1()
//                }
        customTabBarVC.toggleTabs()
    }
    
//    func setupCustomTabBars() {
//           let height: CGFloat = 80
//           let yPosition = self.view.frame.height - height
//           customTabBarContainer = UIView(frame: CGRect(x: 0, y: yPosition, width: view.frame.width, height: height))
//           customTabBarContainer.backgroundColor = .clear
//           self.view.addSubview(customTabBarContainer)
//        
//
//           if let view1 = Bundle.main.loadNibNamed("tab1", owner: self, options: nil)?.first as? tab1 {
//               tabView1 = view1
//               tabView1.frame = customTabBarContainer.bounds
//               tabView1.tap = self
//           }
//
//           if let view2 = Bundle.main.loadNibNamed("tab2", owner: self, options: nil)?.first as? tab2 {
//               tabView2 = view2
//               tabView2.frame = customTabBarContainer.bounds
//           }
//       }
//    func showTab1() {
//            clearTabBar()
//            customTabBarContainer.addSubview(tabView1)
//        }
//
//        func showTab2() {
//            clearTabBar()
//            customTabBarContainer.addSubview(tabView2)
//        }
//
//        func clearTabBar() {
//            for subview in customTabBarContainer.subviews {
//                subview.removeFromSuperview()
//            }
//        }

    @IBAction func onClickClose(_ sender: Any) {
        self.removeFromParent()
        self.popupVC?.view.removeFromSuperview()
        popupVC = nil
    }
    
}

extension ViewController: delegateFunc{
    func didTap() {
        if popupVC == nil {
            print("Opening popup")
            guard let popup = storyboard?.instantiateViewController(withIdentifier: "PopupVC") as? PopupVC else { return }
            self.popupVC = popup
            popup.modalPresentationStyle = .overCurrentContext
            self.present(popup, animated: true, completion: nil)
            
        } else {
            print("Closing popup")
            self.removeFromParent()
            self.popupVC?.view.removeFromSuperview()
        }
    }
}

import UIKit

class CustomTabBarController: UITabBarController {

    var tabView1: tab1!
    var tabView2: tab2!
    var customTabBarContainer: UIView!
    var isTab2Visible = false
    var customDelegate: delegateFunc?

    override func viewDidLoad() {
        super.viewDidLoad()
        setupTabViews()
        showTab1()
    }

    func setupTabViews() {
        let height: CGFloat = 80
        customTabBarContainer = UIView()
        customTabBarContainer.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(customTabBarContainer)

        NSLayoutConstraint.activate([
            customTabBarContainer.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            customTabBarContainer.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            customTabBarContainer.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            customTabBarContainer.heightAnchor.constraint(equalToConstant: height)
        ])

        if let view1 = Bundle.main.loadNibNamed("tab1", owner: self, options: nil)?.first as? tab1 {
            tabView1 = view1
            tabView1.tap = customDelegate
            tabView1.frame = customTabBarContainer.bounds
        }

        if let view2 = Bundle.main.loadNibNamed("tab2", owner: self, options: nil)?.first as? tab2 {
            tabView2 = view2
            tabView2.frame = customTabBarContainer.bounds
        }
    }

    func toggleTabs() {
        isTab2Visible.toggle()
        isTab2Visible ? showTab2() : showTab1()
    }

    func showTab1() {
        customTabBarContainer.subviews.forEach { $0.removeFromSuperview() }
        customTabBarContainer.addSubview(tabView1)
    }

    func showTab2() {
        customTabBarContainer.subviews.forEach { $0.removeFromSuperview() }
        customTabBarContainer.addSubview(tabView2)
    }
}

