<key>NSAppTransportSecurity</key>
    <dict>
        <key>NSAllowsArbitraryLoads</key>
        <true/>
    </dict>

    <key>NSAppTransportSecurity</key>
    <dict>
        <key>NSExceptionDomains</key>
        <dict>
            <key>api.restful-api.dev</key>
            <dict>
                <key>NSExceptionAllowsInsecureHTTPLoads</key>
                <true/>
                <key>NSExceptionMinimumTLSVersion</key>
                <string>TLSv1.2</string>
            </dict>
        </dict>
    </dict>


var arrProducts: [Product] = []
    
    func getProductData() {
        let url = APIS.productBaseUrl

        APIManager.shared.request(url: url, method: .get) { response in
            switch response {
            case .success(let data):
                do {
                    guard let jsonArray = data as? [[String: Any]] else {
                        print("Invalid format: expected array of dictionaries")
                        return
                    }

                    let jsonData = try JSONSerialization.data(withJSONObject: jsonArray)
                    let productList = try JSONDecoder().decode([Product].self, from: jsonData)

                    self.arrProducts.append(contentsOf: productList)
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
func fetchProductDetail(productID: String) {
       
        let url = "https://api.restful-api.dev/objects/\(productID)"
        
        APIManager.shared.request(url: url, method: .get) { response in
            switch response {
            case .success(let data):
                do {
                    guard let json = data as? [String: Any] else { return }
                    let jsonData = try JSONSerialization.data(withJSONObject: json)
                    let product = try JSONDecoder().decode(Product.self, from: jsonData)

//                    DispatchQueue.main.async {
//                        // Update UI with product
//                        self.updateUI(with: product)
//                    }
                } catch {
                    print("Decoding error:", error)
                }
            case .failure(let error):
                print("API Error:", error)
            }
        }
    }




import UIKit
var viewModel = UserViewModel()
var selectedCategoryIndex: Int? = nil

class ProductVC: UIViewController {
//MARK: Outlet and Variable Declaration
    @IBOutlet weak var cvProduct: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUP()
        viewModel.productVC = self
        viewModel.getProductData()
    }
        // Do any additional setup after loading the view.
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: true)
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(true, animated: true)
    }
   
}
    //MARK: SetUp UI
    extension ProductVC{
        func setUP(){
            let nibName = UINib(nibName: "ProductCell", bundle: nil)
            cvProduct.register(nibName, forCellWithReuseIdentifier: "ProductCell")
        }
    }
    //MARK: Custom funcations
    extension ProductVC{
        
    }
    //MARK: UICollectionViewDataSource, UICollectionViewDelegate
    extension ProductVC: UICollectionViewDataSource, UICollectionViewDelegate,UICollectionViewDelegateFlowLayout {
        func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
            return viewModel.arrProducts.count
        }
        
        func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ProductCell", for: indexPath) as! ProductCell
            let products = viewModel.arrProducts[indexPath.item]
            cell.lblName.text = products.name
            cell.lblColor.text = products.data?.color
            return cell
            /*
             func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
                 let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ProductCell", for: indexPath) as! ProductCell
                 let product = viewModel.arrProducts[indexPath.item]

                 cell.lblName.text = product.name

                 guard let data = product.data else {
                     // Hide all labels if data is nil
                     cell.lblColor.isHidden = true
                     cell.lblCapacity.isHidden = true
                     cell.lblPrice.isHidden = true
                     cell.lblGeneration.isHidden = true
                     cell.lblYear.isHidden = true
                     // Continue for all
                     return cell
                 }

                 // Set values or hide labels
                 if let val = data.dataColor ?? data.color {
                     cell.lblColor.text = "Color: \(val)"
                     cell.lblColor.isHidden = false
                 } else {
                     cell.lblColor.isHidden = true
                 }

                 if let val = data.dataCapacity ?? data.capacity {
                     cell.lblCapacity.text = "Capacity: \(val)"
                     cell.lblCapacity.isHidden = false
                 } else if let val = data.capacityGB {
                     cell.lblCapacity.text = "Capacity GB: \(val)"
                     cell.lblCapacity.isHidden = false
                 } else {
                     cell.lblCapacity.isHidden = true
                 }

                 if let val = data.dataPrice ?? Double(data.price ?? "") {
                     cell.lblPrice.text = "Price: \(val)"
                     cell.lblPrice.isHidden = false
                 } else {
                     cell.lblPrice.isHidden = true
                 }

                 if let val = data.dataGeneration ?? data.generation {
                     cell.lblGeneration.text = "Generation: \(val)"
                     cell.lblGeneration.isHidden = false
                 } else {
                     cell.lblGeneration.isHidden = true
                 }

                 if let val = data.year {
                     cell.lblYear.text = "Year: \(val)"
                     cell.lblYear.isHidden = false
                 } else {
                     cell.lblYear.isHidden = true
                 }

                 if let val = data.cpuModel {
                     cell.lblCPUModel.text = "CPU: \(val)"
                     cell.lblCPUModel.isHidden = false
                 } else {
                     cell.lblCPUModel.isHidden = true
                 }

                 if let val = data.hardDiskSize {
                     cell.lblHardDiskSize.text = "HDD: \(val)"
                     cell.lblHardDiskSize.isHidden = false
                 } else {
                     cell.lblHardDiskSize.isHidden = true
                 }

                 if let val = data.screenSize {
                     cell.lblScreenSize.text = "Screen: \(val)\""
                     cell.lblScreenSize.isHidden = false
                 } else {
                     cell.lblScreenSize.isHidden = true
                 }

                 if let val = data.description {
                     cell.lblDescription.text = "Desc: \(val)"
                     cell.lblDescription.isHidden = false
                 } else {
                     cell.lblDescription.isHidden = true
                 }

                 return cell
             }

             */
        }
        func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
            selectedCategoryIndex = indexPath.item
            let selectedProduct = viewModel.arrProducts[indexPath.item]
            let productID = selectedProduct.id
            let story = storyboard?.instantiateViewController(withIdentifier: "ProductDetailVC") as! ProductDetailVC
            story.productID = productID
            story.lblname = selectedProduct.name
            story.lblId = selectedProduct.id
            story.lblColorL = selectedProduct.data?.color
            navigationController?.pushViewController(story, animated: true)
           
            collectionView.reloadData()
        }
        func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
            return CGSize(width: (self.cvProduct.frame.width - 20) / 2, height: self.cvProduct.frame.height)
        }
    }
    //MARK: Click Events
extension ProductVC{
    @IBAction func onClickAddProduct(_ sender: Any) {
        let productDetailVC = storyboard?.instantiateViewController(withIdentifier: "ProductDetailVC") as! ProductDetailVC
        navigationController?.pushViewController(productDetailVC, animated: true)
    }
    @IBAction func onClickback(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
}


import UIKit

class ProductDetailVC: UIViewController {
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var lblID: UILabel!
    @IBOutlet weak var lblColor: UILabel!
    
    
    var lblname: String?
    var lblId: String?
    var lblColorL: String?
    
    var productID: String?
    let viewModel = UserViewModel()
    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel.fetchProductDetail(productID: productID!)
        lblName.text = lblname
        lblID.text = lblId
        lblColor.text = lblColorL
        // Do any additional setup after loading the view.
    }
    
    @IBAction func onClickBack(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    
}

