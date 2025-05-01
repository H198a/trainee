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

