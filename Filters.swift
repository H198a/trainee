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




<key>NSAppTransportSecurity</key>
<dict>
    <key>NSExceptionDomains</key>
    <dict>
        <key>restful-api.dev</key>
        <dict>
            <key>NSIncludesSubdomains</key>
            <true/>
            <key>NSTemporaryExceptionAllowsInsecureHTTPLoads</key>
            <true/>
            <key>NSTemporaryExceptionMinimumTLSVersion</key>
            <string>TLSv1.0</string>
        </dict>
    </dict>
</dict>
