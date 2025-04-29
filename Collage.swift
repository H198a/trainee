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
