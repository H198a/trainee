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



var arrProducts: [Productt] = []
 func getProductData() {
     let url = APIUrls.productBaseUrl

     APIManager.shared.request(url: url, method: .get) { response in
         switch response {
         case .success(let data):
             do {
                 guard let jsonArray = data as? [[String: Any]] else {
                     print("Invalid format: expected array of dictionaries")
                     return
                 }

                 let jsonData = try JSONSerialization.data(withJSONObject: jsonArray)
                 let productList = try JSONDecoder().decode(Productt.self, from: jsonData)

                 self.arrProducts = productList.data
                 DispatchQueue.main.async {
                     self.productVc?.cvProduct.reloadData()
                 }
             } catch {
                 print("Decoding error:", error)
             }
         case .failure(let err):
             print("Request error:", err)
             
         }
     }
 }
 struct Productt: Decodable {
     let data: [Data]
     let source: [Source]
 }

 // MARK: - Datum
 struct Data: Decodable {
     let idNation: IDNation
     let nation: Nation
     let idYear: Int
     let year: String
     let population: Int
     let slugNation: SlugNation

     enum CodingKeys: String, CodingKey {
         case idNation = "ID Nation"
         case nation = "Nation"
         case idYear = "ID Year"
         case year = "Year"
         case population = "Population"
         case slugNation = "Slug Nation"
     }
 }

 enum IDNation: String, Codable {
     case the01000Us = "01000US"
 }

 enum Nation: String, Codable {
     case unitedStates = "United States"
 }

 enum SlugNation: String, Codable {
     case unitedStates = "united-states"
 }

 // MARK: - Source
 struct Source: Codable {
     let measures: [String]
     let annotations: Annotations
     let name: String
     let substitutions: [JSONAny]
 }

 // MARK: - Annotations
 struct Annotations: Codable {
     let sourceName, sourceDescription, datasetName: String
     let datasetLink: String
     let tableID, topic, subtopic: String

     enum CodingKeys: String, CodingKey {
         case sourceName = "source_name"
         case sourceDescription = "source_description"
         case datasetName = "dataset_name"
         case datasetLink = "dataset_link"
         case tableID = "table_id"
         case topic, subtopic
     }
 }

 // MARK: - Encode/decode helpers

 class JSONNull: Codable, Hashable {

     public static func == (lhs: JSONNull, rhs: JSONNull) -> Bool {
             return true
     }

     public var hashValue: Int {
             return 0
     }

     public init() {}

     public required init(from decoder: Decoder) throws {
             let container = try decoder.singleValueContainer()
             if !container.decodeNil() {
                     throw DecodingError.typeMismatch(JSONNull.self, DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Wrong type for JSONNull"))
             }
     }

     public func encode(to encoder: Encoder) throws {
             var container = encoder.singleValueContainer()
             try container.encodeNil()
     }
 }

 class JSONCodingKey: CodingKey {
     let key: String

     required init?(intValue: Int) {
             return nil
     }

     required init?(stringValue: String) {
             key = stringValue
     }

     var intValue: Int? {
             return nil
     }

     var stringValue: String {
             return key
     }
 }

 class JSONAny: Codable {

     let value: Any

     static func decodingError(forCodingPath codingPath: [CodingKey]) -> DecodingError {
             let context = DecodingError.Context(codingPath: codingPath, debugDescription: "Cannot decode JSONAny")
             return DecodingError.typeMismatch(JSONAny.self, context)
     }

     static func encodingError(forValue value: Any, codingPath: [CodingKey]) -> EncodingError {
             let context = EncodingError.Context(codingPath: codingPath, debugDescription: "Cannot encode JSONAny")
             return EncodingError.invalidValue(value, context)
     }

     static func decode(from container: SingleValueDecodingContainer) throws -> Any {
             if let value = try? container.decode(Bool.self) {
                     return value
             }
             if let value = try? container.decode(Int64.self) {
                     return value
             }
             if let value = try? container.decode(Double.self) {
                     return value
             }
             if let value = try? container.decode(String.self) {
                     return value
             }
             if container.decodeNil() {
                     return JSONNull()
             }
             throw decodingError(forCodingPath: container.codingPath)
     }

     static func decode(from container: inout UnkeyedDecodingContainer) throws -> Any {
             if let value = try? container.decode(Bool.self) {
                     return value
             }
             if let value = try? container.decode(Int64.self) {
                     return value
             }
             if let value = try? container.decode(Double.self) {
                     return value
             }
             if let value = try? container.decode(String.self) {
                     return value
             }
             if let value = try? container.decodeNil() {
                     if value {
                             return JSONNull()
                     }
             }
             if var container = try? container.nestedUnkeyedContainer() {
                     return try decodeArray(from: &container)
             }
             if var container = try? container.nestedContainer(keyedBy: JSONCodingKey.self) {
                     return try decodeDictionary(from: &container)
             }
             throw decodingError(forCodingPath: container.codingPath)
     }

     static func decode(from container: inout KeyedDecodingContainer<JSONCodingKey>, forKey key: JSONCodingKey) throws -> Any {
             if let value = try? container.decode(Bool.self, forKey: key) {
                     return value
             }
             if let value = try? container.decode(Int64.self, forKey: key) {
                     return value
             }
             if let value = try? container.decode(Double.self, forKey: key) {
                     return value
             }
             if let value = try? container.decode(String.self, forKey: key) {
                     return value
             }
             if let value = try? container.decodeNil(forKey: key) {
                     if value {
                             return JSONNull()
                     }
             }
             if var container = try? container.nestedUnkeyedContainer(forKey: key) {
                     return try decodeArray(from: &container)
             }
             if var container = try? container.nestedContainer(keyedBy: JSONCodingKey.self, forKey: key) {
                     return try decodeDictionary(from: &container)
             }
             throw decodingError(forCodingPath: container.codingPath)
     }

     static func decodeArray(from container: inout UnkeyedDecodingContainer) throws -> [Any] {
             var arr: [Any] = []
             while !container.isAtEnd {
                     let value = try decode(from: &container)
                     arr.append(value)
             }
             return arr
     }

     static func decodeDictionary(from container: inout KeyedDecodingContainer<JSONCodingKey>) throws -> [String: Any] {
             var dict = [String: Any]()
             for key in container.allKeys {
                     let value = try decode(from: &container, forKey: key)
                     dict[key.stringValue] = value
             }
             return dict
     }
 //
     static func encode(to container: inout UnkeyedEncodingContainer, array: [Any]) throws {
             for value in array {
                     if let value = value as? Bool {
                             try container.encode(value)
                     } else if let value = value as? Int64 {
                             try container.encode(value)
                     } else if let value = value as? Double {
                             try container.encode(value)
                     } else if let value = value as? String {
                             try container.encode(value)
                     } else if value is JSONNull {
                             try container.encodeNil()
                     } else if let value = value as? [Any] {
                             var container = container.nestedUnkeyedContainer()
                             try encode(to: &container, array: value)
                     } else if let value = value as? [String: Any] {
                             var container = container.nestedContainer(keyedBy: JSONCodingKey.self)
                             try encode(to: &container, dictionary: value)
                     } else {
                             throw encodingError(forValue: value, codingPath: container.codingPath)
                     }
             }
     }

     static func encode(to container: inout KeyedEncodingContainer<JSONCodingKey>, dictionary: [String: Any]) throws {
             for (key, value) in dictionary {
                     let key = JSONCodingKey(stringValue: key)!
                     if let value = value as? Bool {
                             try container.encode(value, forKey: key)
                     } else if let value = value as? Int64 {
                             try container.encode(value, forKey: key)
                     } else if let value = value as? Double {
                             try container.encode(value, forKey: key)
                     } else if let value = value as? String {
                             try container.encode(value, forKey: key)
                     } else if value is JSONNull {
                             try container.encodeNil(forKey: key)
                     } else if let value = value as? [Any] {
                             var container = container.nestedUnkeyedContainer(forKey: key)
                             try encode(to: &container, array: value)
                     } else if let value = value as? [String: Any] {
                             var container = container.nestedContainer(keyedBy: JSONCodingKey.self, forKey: key)
                             try encode(to: &container, dictionary: value)
                     } else {
                             throw encodingError(forValue: value, codingPath: container.codingPath)
                     }
             }
     }

     static func encode(to container: inout SingleValueEncodingContainer, value: Any) throws {
             if let value = value as? Bool {
                     try container.encode(value)
             } else if let value = value as? Int64 {
                     try container.encode(value)
             } else if let value = value as? Double {
                     try container.encode(value)
             } else if let value = value as? String {
                     try container.encode(value)
             } else if value is JSONNull {
                     try container.encodeNil()
             } else {
                     throw encodingError(forValue: value, codingPath: container.codingPath)
             }
     }

     public required init(from decoder: Decoder) throws {
             if var arrayContainer = try? decoder.unkeyedContainer() {
                     self.value = try JSONAny.decodeArray(from: &arrayContainer)
             } else if var container = try? decoder.container(keyedBy: JSONCodingKey.self) {
                     self.value = try JSONAny.decodeDictionary(from: &container)
             } else {
                     let container = try decoder.singleValueContainer()
                     self.value = try JSONAny.decode(from: container)
             }
     }

     public func encode(to encoder: Encoder) throws {
             if let arr = self.value as? [Any] {
                     var container = encoder.unkeyedContainer()
                     try JSONAny.encode(to: &container, array: arr)
             } else if let dict = self.value as? [String: Any] {
                     var container = encoder.container(keyedBy: JSONCodingKey.self)
                     try JSONAny.encode(to: &container, dictionary: dict)
             } else {
                     var container = encoder.singleValueContainer()
                     try JSONAny.encode(to: &container, value: self.value)
             }
     }
 }
 self.arrProducts = productList.data
 Cannot assign value of type '[Data]' to type '[Productt]'
