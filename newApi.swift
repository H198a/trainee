extension ProductDetailVC{
    @IBAction func onClickBack(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    @IBAction func onCLickUpdate(_ sender: Any) {
        showBtn = true
        btnUpdate.isHidden = true
        btnSubmit.isHidden = false
        txtID.isUserInteractionEnabled = true
        txtNation.isUserInteractionEnabled = true
        txtYear.isUserInteractionEnabled = true
        txtPopulation.isUserInteractionEnabled = true
        txtIdYear.isUserInteractionEnabled = true
        txtSlugNation.isUserInteractionEnabled = true
    }
    
    @IBAction func onCLickAddAndUpdate(_ sender: Any) {
        guard let id = txtID.text, !id.isEmpty else {
            print("something wrong in id")
            return
        }
        guard let nation = txtIdYear.text, !nation.isEmpty else{//year
            print("something wrong in nation")
            return
        }
        guard let idYear = txtNation.text, !idYear.isEmpty else{//nation
            print("somthing wrong in idyear")
            return
        }
        guard let year = txtYear.text, !year.isEmpty else{
            print("somethinf wrong in year")
            return
        }
        guard let population = txtPopulation.text, !population.isEmpty else{
            print("something wrong in population")
            return
        }
        guard let slugNation = txtSlugNation.text, !slugNation.isEmpty else{
            print("something wrong in slugNation")
            return
        }
        
//        let param: [String: Any] = [
//            "ID Nation": currentUserId!,
//            "Nation": nation,
//            "ID Year": idYear,
//            "Year": year,
//            "Population": population,
//            "Slug Nation": slugNation
//        ]
        let url = APIS.productBaseUrl
        APIManager.shared.request(url: url, method: .get/*, parameters: param*/) { result in
            switch result{
            case .success(let data):
                do{
                    guard let jsonDict = data as? [String: Any] else {
                        print("Invalid JSON structure")
                        return
                    }
                    let jsonData = try JSONSerialization.data(withJSONObject: jsonDict)
                    let product = try JSONDecoder().decode(Productt.self, from: jsonData)
                    guard let newProduct = product.data.first else {
                        print("No product data found")
                        return
                    }
                    print("responseee----------------",newProduct)
                    self.completionHandler?(newProduct)
                    self.navigationController?.popViewController(animated: true)
                } catch{
                    print("decoding error",error)
                }
            case .failure(let err):
                print("add error in UserViewModel:=====",err)
            }
        }
    }
}





    func getProductData() {
        let url = APIS.productBaseUrl

        APIManager.shared.request(url: url, method: .get) { response in
            switch response {
            case .success(let data):
                do {
                    guard let jsonArray = data as? [String: Any] else {
                        print("Invalid format: expected array of dictionaries")
                        return
                    }

                    let jsonData = try JSONSerialization.data(withJSONObject: jsonArray)
                    let productList = try JSONDecoder().decode(Productt.self, from: jsonData)

                    self.arrProducts.append(contentsOf: productList.data)
                    DispatchQueue.main.async {
                        self.productVC?.cvProduct.reloadData()
                    }
                } catch {
                    print("Decoding error:", error)
                }
            case .failure(let err):
                print("Request error:", err)
                
            }
        }
    }


extension ProductVC{
    @IBAction func onClickAddProduct(_ sender: Any) {
        let productDetailVC = storyboard?.instantiateViewController(withIdentifier: "ProductDetailVC") as! ProductDetailVC
        productDetailVC.showBtn = false
        productDetailVC.currentUserId = self.currentUserId
        productDetailVC.completionHandler = { newProduct in
            self.viewModel.arrProducts.insert(newProduct, at: 0)
            self.cvProduct.reloadData()
            DispatchQueue.main.async{
                self.cvProduct.setContentOffset(.zero, animated: true)
            }
        }
        navigationController?.pushViewController(productDetailVC, animated: true)
    }
    @IBAction func onClickback(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
}


import UIKit
import Alamofire

class ProductDetailVC: UIViewController {
    @IBOutlet weak var lblHeading: UILabel!
    @IBOutlet weak var btnUpdate: UIButton!
    @IBOutlet weak var btnAddAndUpdate: UIButton!
    @IBOutlet weak var txtNation: UITextField!
//    @IBOutlet weak var txtID: UITextField!
//    @IBOutlet weak var txtIdYear: UITextField!
    @IBOutlet weak var txtYear: UITextField!
//    @IBOutlet weak var txtPopulation: UITextField!
//    @IBOutlet weak var txtSlugNation: UITextField!
    @IBOutlet weak var btnSubmit: UIButton!
    var viewModel = PostsViewModel()
    var showBtn: Bool = false
    var productData: Dataa?
    var completionHandler: ((Dataa) -> Void)?
    var currentUserId: IDNation?
    override func viewDidLoad() {
        super.viewDidLoad()
        setUP()
        getProductDetails()
    }
}
//MARK: setup UI
extension ProductDetailVC{
    func setUP(){
        if showBtn{
            lblHeading.text = "Details"
            btnSubmit.isHidden = true
            txtNation.isUserInteractionEnabled = false
            txtYear.isUserInteractionEnabled = false
        } else{
            btnUpdate.isHidden = true
            lblHeading.text = "Update Details"
            btnSubmit.isHidden = false
            btnSubmit.setTitle("Save", for: .normal)
            txtNation.isUserInteractionEnabled = true
            txtYear.isUserInteractionEnabled = true
        }
  
        lblHeading.font = .setFont(type: .Bold, size: 24)
        let attributedString = NSAttributedString(
            string: "Update Details",
            attributes: [
                .foregroundColor: UIColor.btn,
                .font: UIFont.setFont(type: .Bold, size: 16)
            ]
        )
        btnUpdate.setAttributedTitle(attributedString, for: .normal)
    }
}
//MARK: Custom Functions
extension ProductDetailVC{
    func getProductDetails(){
        if let user = productData{
            txtNation.text = " \(user.nation)"
            txtYear.text = " \(user.year)"
        }
    }
    func showAlert(message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
}
//MARK: Click Events
extension ProductDetailVC{
    @IBAction func onClickBack(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    @IBAction func onClickUpdateDetails(_ sender: Any) {
        lblHeading.text = "Update Details"
        showBtn = true
        btnUpdate.isHidden = true
        btnSubmit.isHidden = false
        btnSubmit.setTitle("Save", for: .normal)
        txtNation.isUserInteractionEnabled = true
    }
    @IBAction func onClickAddAndUpdate(_ sender: Any) {
        
//        guard let id = txtID.text, !id.isEmpty else {
//            print("something wrong in id")
//            return
//        }
//        guard let nation = txtIdYear.text, !nation.isEmpty else{//year
//            print("something wrong in nation")
//            return
//        }
        guard let idYear = txtNation.text, !idYear.isEmpty else{//nation
            print("somthing wrong in idyear")
            return
        }
        guard let year = txtYear.text, !year.isEmpty else{
            print("somethinf wrong in year")
            return
        }
//        guard let population = txtPopulation.text, !population.isEmpty else{
//            print("something wrong in population")
//            return
//        }
//        guard let slugNation = txtSlugNation.text, !slugNation.isEmpty else{
//            print("something wrong in slugNation")
//            return
//        }
        
        //        let param: [String: Any] = [
        //            "ID Nation": currentUserId!,
        //            "Nation": nation,
        //            "ID Year": idYear,
        //            "Year": year,
        //            "Population": population,
        //            "Slug Nation": slugNation
        //        ]
//        let url = APIUrls.productBaseUrl
//        APIManager.shared.request(url: url, method: .get/*, parameters: param*/) { result in
//            switch result{
//            case .success(let data):
//                do{
//                    guard let jsonDict = data as? [String: Any] else {
//                        print("Invalid JSON structure")
//                        return
//                    }
//                    let jsonData = try JSONSerialization.data(withJSONObject: jsonDict)
//                    let product = try JSONDecoder().decode(Productt.self, from: jsonData)
//                    guard let newProduct = product.data.first else {
//                        print("No product data found")
//                        return
//                    }
//                    print("responseee----------------",newProduct)
//                    self.completionHandler?(newProduct)
//                    self.navigationController?.popViewController(animated: true)
//                    self.showAlert(message: "Prodcut added successfully!")
//                } catch{
//                    print("decoding error",error)
//                    self.showAlert(message: "cant add product due to decoding error")
//                }
//            case .failure(let err):
//                self.showAlert(message: "failure")
//                print("add error in UserViewModel:=====",err)
//            }
//        }
    }
}

  @IBAction func onClickAddProduct(_ sender: Any) {
        let productDetailVC = storyboard?.instantiateViewController(withIdentifier: "ProductDetailVC") as! ProductDetailVC
        productDetailVC.showBtn = false
        productDetailVC.currentUserId = self.cuurentUserId
        productDetailVC.completionHandler = { newProduct in
            self.viewModel.arrProducts.insert(newProduct, at: 0)
            self.cvProduct.reloadData()
            DispatchQueue.main.async{
                self.cvProduct.setContentOffset(.zero, animated: true)
            }
        }
        navigationController?.pushViewController(productDetailVC, animated: true)
    }
