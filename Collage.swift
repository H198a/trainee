genum CollageLayoutType: CaseIterable {
    case grid, vertical, horizontal

    var layout: ABCollageLayout {
        switch self {
        case .grid:
            return ABCollageLayout.grid(columns: 2)
        case .vertical:
            return ABCollageLayout.vertical(rows: 2)
        case .horizontal:
            return ABCollageLayout.horizontal(columns: 2)
        }
    }
}



import UIKit
import ABCollageView

class CollageViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {

    @IBOutlet weak var frameCollectionView: UICollectionView!
    @IBOutlet weak var collageContainer: UIView!
    
    var collageView: ABCollageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        frameCollectionView.delegate = self
        frameCollectionView.dataSource = self
        
        // Initialize with default layout
        setupCollageView(layout: CollageLayoutType.grid.layout)
    }
    
    func setupCollageView(layout: ABCollageLayout) {
        // Remove previous collage view if exists
        collageView?.removeFromSuperview()
        
        collageView = ABCollageView(frame: collageContainer.bounds, layout: layout)
        collageView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        collageContainer.addSubview(collageView)
    }
    
    // MARK: Collection View
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return CollageLayoutType.allCases.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        // Use a basic cell to preview layout (customize as needed)
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "FrameCell", for: indexPath)
        cell.contentView.backgroundColor = .lightGray // Just a placeholder
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let selectedLayout = CollageLayoutType.allCases[indexPath.item].layout
        setupCollageView(layout: selectedLayout)
    }
}




enum CollageLayoutType: CaseIterable {
    case grid, vertical, horizontal

    var layout: ABCollageLayout {
        switch self {
        case .grid:
            return ABCollageLayout.grid(columns: 2)
        case .vertical:
            return ABCollageLayout.vertical(rows: 2)
        case .horizontal:
            return ABCollageLayout.horizontal(columns: 2)
        }
    }
}

func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    let selectedLayout = CollageLayoutType.allCases[indexPath.item].layout
    setupCollageView(layout: selectedLayout)
}
func setupCollageView(layout: ABCollageLayout) {
    // Remove old collage view if present
    collageView?.removeFromSuperview()

    // Initialize and configure new collage view
    collageView = ABCollageView(frame: collageContainer.bounds, layout: layout)
    collageView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
    collageView.backgroundColor = .lightGray
    collageContainer.addSubview(collageView)

    // Add tap gestures to each slot
    for (index, slot) in collageView.slots.enumerated() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleSlotTap(_:)))
        slot.tag = index
        slot.isUserInteractionEnabled = true
        slot.addGestureRecognizer(tapGesture)
    }
}


func presentMultipleImagePicker() {
    var config = PHPickerConfiguration()
    config.selectionLimit = collageView.slots.count // Limit to slot count
    config.filter = .images

    let picker = PHPickerViewController(configuration: config)
    picker.delegate = self
    present(picker, animated: true, completion: nil)
}
extension CollageViewController: PHPickerViewControllerDelegate {
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        picker.dismiss(animated: true, completion: nil)
        
        var imageIndex = 0
        for result in results {
            if imageIndex >= collageView.slots.count { break }

            if result.itemProvider.canLoadObject(ofClass: UIImage.self) {
                result.itemProvider.loadObject(ofClass: UIImage.self) { [weak self] object, error in
                    guard let self = self, let image = object as? UIImage else { return }

                    DispatchQueue.main.async {
                        self.collageView.slots[imageIndex].image = image
                        imageIndex += 1
                    }
                }
            }
        }
    }
}
func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    let selectedLayout = CollageLayoutType.allCases[indexPath.item].layout
    setupCollageView(layout: selectedLayout)
    presentMultipleImagePicker()
}







 import UIKit

 class ProductVC: UIViewController {
 //MARK: Outlet and Variable Declaration
     @IBOutlet weak var cvProduct: UICollectionView!
     @IBOutlet weak var lblHeading: UILabel!
     var viewModel = PostsViewModel()
     var selectedCategoryIndex: Int? = nil
     var cuurentUserId: String?
     
     override func viewDidLoad() {
         super.viewDidLoad()
         viewModel.productVc = self
         setUP()
         viewModel.getProductData()
     }
     override func viewWillAppear(_ animated: Bool) {
         super.viewWillAppear(animated)
         navigationController?.setNavigationBarHidden(true, animated: true)
     }
     override func viewWillDisappear(_ animated: Bool) {
         super.viewWillDisappear(animated)
         navigationController?.setNavigationBarHidden(true, animated: true)
     }
     @objc func handleLongPress(_ gesture: UILongPressGestureRecognizer) {
         if gesture.state == .began {
             let point = gesture.location(in: cvProduct)
             if let indexPath = cvProduct.indexPathForItem(at: point) {
                 //Confirm deletion with  alert
                 let alert = UIAlertController(title: "Delete", message: "Do you want to delete this product?", preferredStyle: .alert)
                 alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
                 alert.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: { _ in
                     self.viewModel.arrProducts.remove(at: indexPath.item)
                     self.cvProduct.deleteItems(at: [indexPath])
                 }))
                 self.present(alert, animated: true, completion: nil)
             }
         }
     }
 }
 //MARK: SetUp UI
 extension ProductVC{
     func setUP(){
         let nibName = UINib(nibName: "ProductCell", bundle: nil)
         cvProduct.register(nibName, forCellWithReuseIdentifier: "ProductCell")
         lblHeading.font = .setFont(type: .Bold, size: 24)
         let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress(_:)))
         cvProduct.addGestureRecognizer(longPressGesture)
     }
 }
 //MARK: UICollectionViewDataSource, UICollectionViewDelegate
 extension ProductVC: UICollectionViewDataSource, UICollectionViewDelegate,UICollectionViewDelegateFlowLayout {
     func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
         return viewModel.arrProducts.count
     }
     
     func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
         let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ProductCell", for: indexPath) as! ProductCell
         let products = viewModel.arrProducts[indexPath.item]
         cell.lblName.text = "\(products.nation)"
         cell.lblColor.text = products.year
         cell.lblnationId.text = "\(products.idNation)"
         cell.lblPopulation.text = "\(products.population)"
         cell.lblSlugnation.text = "\(products.slugNation)"
         self.cuurentUserId = products.idNation
         return cell
     }
     func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
         selectedCategoryIndex = indexPath.item
         let selectedProduct = viewModel.arrProducts[indexPath.item]
         let details = storyboard?.instantiateViewController(withIdentifier: "ProductDetailVC") as! ProductDetailVC
         details.productData = selectedProduct
         details.showBtn = true
         details.isUpdateMode = true
         
         details.completionHandler = { updatedProduct in
             if let index = self.viewModel.arrProducts.firstIndex(where: { $0.population == updatedProduct.population }) {
                 self.viewModel.arrProducts[index] = updatedProduct
                 collectionView.reloadData()
                 self.cvProduct.reloadItems(at: [IndexPath(item: index, section: 0)])
             } else{
                 print("population not found")
             }
         }
         
         navigationController?.pushViewController(details, animated: true)
       
     }
     func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
         return CGSize(width: (self.cvProduct.frame.width - 10) / 2, height: 156)
     }
 }
 //MARK: Click Events
 extension ProductVC{
     @IBAction func onClickAddProduct(_ sender: Any) {
         let productDetailVC = storyboard?.instantiateViewController(withIdentifier: "ProductDetailVC") as! ProductDetailVC
         productDetailVC.showBtn = false
         productDetailVC.isUpdateMode = false
         productDetailVC.currentUserId = self.cuurentUserId
         
         productDetailVC.completionHandler = { newProduct in
             // Check if product already exists
             if let index = self.viewModel.arrProducts.firstIndex(where: { $0.population == newProduct.population }) {
                print("updateeeee")
                 self.viewModel.arrProducts[index] = newProduct // UPDATE
             } else {
                 print("adddddddd")
                 self.viewModel.arrProducts.insert(newProduct, at: 0) // ADD
             }

             self.cvProduct.reloadData()
             DispatchQueue.main.async {
                 self.cvProduct.setContentOffset(.zero, animated: true)
             }
         }
         navigationController?.pushViewController(productDetailVC, animated: true)
     }
     @IBAction func onClickProductDetail(_ sender: Any) {
         let detailVC = storyboard?.instantiateViewController(withIdentifier: "DetailVC") as! DetailVC
         navigationController?.pushViewController(detailVC, animated: true)
     }
     @IBAction func onClickBack(_ sender: UIButton) {
         navigationController?.popViewController(animated: true)
     }
 }

---product detail vc
 import UIKit
 import Alamofire
 import CountryPickerView

 class ProductDetailVC: UIViewController {
     @IBOutlet weak var lblHeading: UILabel!
     @IBOutlet weak var btnUpdate: UIButton!
     @IBOutlet weak var btnAddAndUpdate: UIButton!
     @IBOutlet weak var txtNation: UITextField!
     @IBOutlet weak var txtID: UITextField!
     @IBOutlet weak var txtIdYear: UITextField!
     @IBOutlet weak var txtYear: UITextField!
     @IBOutlet weak var txtPopulation: UITextField!
     @IBOutlet weak var txtSlugNation: UITextField!
     @IBOutlet weak var btnSubmit: UIButton!
     @IBOutlet weak var imgNation: UIImageView!
     @IBOutlet weak var btnNationDropDown: UIButton!
     
     let countryPicker = CountryPickerView()
     var viewModel = PostsViewModel()
     var isUpdateMode = false
     var showBtn: Bool = false
     var productData: Dataa?
     var completionHandler: ((Dataa) -> Void)?
     var currentUserId: String?
     override func viewDidLoad() {
         super.viewDidLoad()
         setUP()
         getProductDetails()
     }
 }
 //MARK: setup UI
 extension ProductDetailVC{
     func setUP(){
         countryPicker.delegate = self
         btnNationDropDown.isHidden = true
         imgNation.image = UIImage(named: "US")
         configureFieldsForMode()
         
         if showBtn{
             btnNationDropDown.isHidden = true
             lblHeading.text = "Details"
             btnSubmit.isHidden = true
             txtID.isUserInteractionEnabled = false
             txtNation.isUserInteractionEnabled = false
             txtYear.isUserInteractionEnabled = false
             txtPopulation.isUserInteractionEnabled = false
             txtIdYear.isUserInteractionEnabled = false
             txtSlugNation.isUserInteractionEnabled = false
         } else{
             btnNationDropDown.isHidden = false
             btnUpdate.isHidden = true
             lblHeading.text = "Update Details"
             btnSubmit.isHidden = false
             btnSubmit.setTitle("Save", for: .normal)
             txtNation.isUserInteractionEnabled = true
             txtYear.isUserInteractionEnabled = true
             txtPopulation.isUserInteractionEnabled = true
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
             txtID.text = " \(user.idNation)"
             txtNation.text = " \(user.nation)"
             txtYear.text = " \(user.year)"
             txtPopulation.text = " \(user.population)"
             txtSlugNation.text = " \(user.slugNation)"
             txtIdYear.text = " \(user.idYear)"
         }
     }
     func configureFieldsForMode() {
         // Hide these fields only in Add mode
         let shouldHideExtraFields = !isUpdateMode

         txtID.isHidden = shouldHideExtraFields
         txtIdYear.isHidden = shouldHideExtraFields
         txtPopulation.isHidden = shouldHideExtraFields
         txtSlugNation.isHidden = shouldHideExtraFields
     }
     func updateBtn(){
         btnNationDropDown.isHidden = false
         lblHeading.text = "Update Details"
         showBtn = true
         btnUpdate.isHidden = true
         btnSubmit.isHidden = false
         btnSubmit.setTitle("Save", for: .normal)
         txtNation.isUserInteractionEnabled = true
         txtYear.isUserInteractionEnabled = true
         txtPopulation.isUserInteractionEnabled = true
     }
     func showAlert(message: String) {
         let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
         alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
         present(alert, animated: true, completion: nil)
     }
 }
 //MARK: Custom Functions
 extension ProductDetailVC{
     func editButton(_ button: UIButton, in collectionView: UICollectionView) -> IndexPath? {
         let buttonPosition = button.convert(CGPoint.zero, to: collectionView)
         return collectionView.indexPathForItem(at: buttonPosition)
     }
 }
 //MARK: CountryPickerViewDelegate
 extension ProductDetailVC: CountryPickerViewDelegate{
     func countryPickerView(_ countryPickerView: CountryPickerView, didSelectCountry country: Country) {
         txtNation.text = country.name
         imgNation.image = country.flag
     }
 }
 //MARK: Click Events
 extension ProductDetailVC{
     @IBAction func onClickBack(_ sender: Any) {
         navigationController?.popViewController(animated: true)
     }
     @IBAction func onClickNationDropDown(_ sender: UIButton) {
         countryPicker.showCountriesList(from: self)
     }
     @IBAction func onClickUpdateDetails(_ sender: Any) {
         updateBtn()
     }
     @IBAction func onClickAddAndUpdate(_ sender: Any) {
         let population: Int
         if let popText = txtPopulation.text, let pop = Int(popText) {
             population = pop
         } else {
             print("error--------------")
             population = Int.random(in: 100_000_000...999_999_999)
         }
 //        let idd = "\(Int.random(in: 1000...9999))"
 //        let pop = Int.random(in: 100_000_000...999_999_999)
         let id = isUpdateMode ? (productData?.idNation ?? "") : "\(Int.random(in: 1000...9999))US"
         guard let idYear = txtYear.text, !idYear.isEmpty else{//nation
             print("somthing wrong in idyear")
             return
         }
         guard let year = txtNation.text, !year.isEmpty else{
             print("somethinf wrong in year")
             return
         }
         
         let updatedProduct = Dataa(
             idNation: id,
             nation: year,
             idYear: Int(idYear) ?? 2020,
             year: idYear,
             population: population,
             slugNation: year
         )

 //        let newProduxt = Dataa(idNation: id, nation: year, idYear: Int(idYear) ?? 2020, year: idYear, population: population, slugNation: year)
 //        completionHandler?(newProduxt)
 //        completionHandler?(updatedProduct)
 //        self.navigationController?.popViewController(animated: true)
 //        self.showAlert(message: "Prodcut added successfully!")
         completionHandler?(updatedProduct)
         navigationController?.popViewController(animated: true)
         showAlert(message: isUpdateMode ? "Product updated successfully!" : "Product added successfully!")
     }
 }
--product struct
 struct Productt: Decodable {
     let data: [Dataa]
     let source: [Source]
 }

 // MARK: - Datum
 struct Dataa: Codable {
     let idNation: String
     let nation: String
     let idYear: Int
     let year: String
     let population: Int
     let slugNation: String

     enum CodingKeys: String, CodingKey {
         case idNation = "ID Nation"
         case nation = "Nation"
         case idYear = "ID Year"
         case year = "Year"
         case population = "Population"
         case slugNation = "Slug Nation"
     }
 }
