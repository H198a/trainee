import UIKit
var arrStoryUsers: [StoryData] = [StoryData(name: "Lily", image: UIImage(named: "img10")!,storyImage:[UIImage(named: "img1")!,UIImage(named: "img2")!]),//1
        StoryData(name: "Allena", image: UIImage(named: "img2")!,storyImage:[UIImage(named: "img1")!,UIImage(named: "img2")!,UIImage(named: "img3")!,UIImage(named: "img4")!]),//4
        StoryData(name: "Stevie", image: UIImage(named: "img3")!,storyImage:[UIImage(named: "img1")!,UIImage(named: "img2")!,UIImage(named: "img3")!,UIImage(named: "img4")!]),//4
                                  
        StoryData(name: "Riya", image: UIImage(named: "img4")!,storyImage:[UIImage(named: "img1")!,UIImage(named: "img2")!,UIImage(named: "img3")!,UIImage(named: "img4")!,UIImage(named:"img5")!,UIImage(named: "img1")!,UIImage(named: "img2")!,UIImage(named: "img3")!,UIImage(named: "img4")!]),//5
        StoryData(name: "Rousy", image: UIImage(named: "img5")!,storyImage:[UIImage(named: "img1")!,UIImage(named: "img2")!,UIImage(named: "img3")!,UIImage(named: "img4")!,UIImage(named: "img5")!]),//5
        StoryData(name: "John", image: UIImage(named: "img6")!,storyImage:[UIImage(named: "img1")!,UIImage(named: "img2")!,UIImage(named: "img3")!,UIImage(named: "img4")!]),//4
        StoryData(name: "Julien", image: UIImage(named: "img7")!,storyImage:[UIImage(named: "img1")!,UIImage(named: "img2")!,UIImage(named: "img3")!]),//3
        StoryData(name: "Amaya", image: UIImage(named: "img8")!,storyImage:[UIImage(named: "img1")!,UIImage(named: "img2")!]),//2
        StoryData(name: "Charlie", image: UIImage(named: "img9")!,storyImage:[UIImage(named: "img1")!,UIImage(named: "img2")!,UIImage(named: "img3")!,UIImage(named: "img4")!]),//2
        StoryData(name: "Kelly", image: UIImage(named: "img10")!,storyImage:[UIImage(named: "img1")!,UIImage(named: "img2")!,UIImage(named: "img3")!])//2
]
class StoryVC: UIViewController {
    //MARK: Outlet and Variable Declaration
    @IBOutlet weak var cvStory: UICollectionView!
   
    override func viewDidLoad() {
        super.viewDidLoad()
        setUP()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: true)
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(true, animated: true)
    }
}
//MARK: Setup UI
extension StoryVC{
    func setUP(){
        let nibName = UINib(nibName: "StoryCell", bundle: nil)
        cvStory.register(nibName, forCellWithReuseIdentifier: "StoryCell")
    }
}
//MARK: UICollectionViewDelegate, UICollectionViewDataSource
extension StoryVC: UICollectionViewDelegate, UICollectionViewDataSource{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return arrStoryUsers.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "StoryCell", for: indexPath) as! StoryCell
        let data = arrStoryUsers[indexPath.item]
        cell.imgStory.image = data.image
        cell.lblName.text = data.name
        cell.configureBorder(isSeen: data.isSeen)
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        arrStoryUsers[indexPath.item].isSeen = true
        cvStory.reloadItems(at: [indexPath])
        let storyVC = storyboard?.instantiateViewController(withIdentifier: "StoryViewVC") as! StoryViewVC
        storyVC.storyDataa = arrStoryUsers
        storyVC.stories = arrStoryUsers[indexPath.item].storyImage
        storyVC.currentUserIndex = indexPath.item
        navigationController?.pushViewController(storyVC, animated: true)
    }
}
import UIKit

protocol StoryViewCellDelegate: AnyObject {
    func didFinishStories(for userIndex: Int)
}

class StoryViewCell: UICollectionViewCell {
//MARK: Outlet and Variable Declaration
    @IBOutlet weak var subImg: UIImageView!
    @IBOutlet weak var lblStory: UILabel!
    @IBOutlet weak var progressStack: UIStackView!
    @IBOutlet weak var cvSubStories: UICollectionView!
    
     var progressBars: [UIProgressView] = []
    var arrImgs:[UIImage] = []
     var currentIndex = 0// // Story index for current use
    var storyDuration: TimeInterval = 3.0
    private var storyTimer: Timer?
    
    weak var delegate: StoryViewCellDelegate?
    var allUsers: [StoryData]?
    var currentUserIndex: Int = 0// Index of currently playing user
   // private var isAnimating = false
    override func prepareForReuse() {
        super.prepareForReuse()
        arrImgs = []
        currentIndex = 0
        progressBars.forEach { $0.removeFromSuperview() }
        progressBars = []
        cvSubStories.setContentOffset(.zero, animated: false)
        cvSubStories.dataSource = nil
        cvSubStories.delegate = nil
        storyTimer?.invalidate()
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        let nibName = UINib(nibName: "SubStoriesCell", bundle: nil)
        cvSubStories.register(nibName, forCellWithReuseIdentifier: "SubStoriesCell")
       
        cvSubStories.showsHorizontalScrollIndicator = false
        cvSubStories.translatesAutoresizingMaskIntoConstraints = false
        cvSubStories.layoutIfNeeded()
        cvSubStories.setContentOffset(.zero, animated: false)
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
               self.addGestureRecognizer(tapGesture)
    }
    func configure(with user: StoryData, userIndex: Int) {
        currentUserIndex = userIndex
        lblStory.text = user.name
        subImg.image = user.image
        arrImgs = user.storyImage

        cvSubStories.dataSource = self
        cvSubStories.delegate = self
        cvSubStories.setContentOffset(.zero, animated: false)

        setupProgressBars()
        cvSubStories.reloadData()

        // Start story only after collection view finishes layout
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
            if !self.arrImgs.isEmpty {
                self.startStory()
            }
        }
    }
    func previousStory() {
            if currentIndex > 0 {
                currentIndex -= 1
                resetProgressBars(from: currentIndex)
                showImage(at: currentIndex)
                animateProgressBar(at: currentIndex)
            }
            // If already at first story, do nothing or handle backward user navigation if needed
        }

        func resetProgressBars(from index: Int) {
            for i in index..<progressBars.count {
                progressBars[i].setProgress(0.0, animated: false)
            }
        }

    @objc func handleTap(_ gesture: UITapGestureRecognizer) {
            let location = gesture.location(in: self)
            let isLeftSide = location.x < self.bounds.width / 2

            storyTimer?.invalidate() // stop current timer

            if isLeftSide {
                previousStory()
            } else {
                nextStory()
            }
        }
    
    func setupProgressBars() {
        progressStack.arrangedSubviews.forEach { $0.removeFromSuperview() }
        progressBars.removeAll()

        for _ in arrImgs {
            let progress = UIProgressView(progressViewStyle: .default)
            progress.progressTintColor = .systemPink
            progress.trackTintColor = UIColor.lightGray
            progress.progress = 0.0
            progress.translatesAutoresizingMaskIntoConstraints = false
            progress.heightAnchor.constraint(equalToConstant: 2).isActive = true

            progressStack.addArrangedSubview(progress)
            progressBars.append(progress)
        }
    }
    func startStory() {
        guard !arrImgs.isEmpty else { print("something wrong in starting story"); return }
        currentIndex = 0
        showImage(at: currentIndex)
        animateProgressBar(at: currentIndex)
    }
    func showImage(at index: Int) {
        cvSubStories.layoutIfNeeded()
        cvSubStories.isPagingEnabled = false
        let indexPath = IndexPath(item: index, section: 0)
        cvSubStories.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: false)
        cvSubStories.isPagingEnabled = true
    }

    func animateProgressBar(at index: Int) {
        guard index < progressBars.count else { return }

        let currentProgress = progressBars[index]
        currentProgress.setProgress(0.0, animated: false)

        UIView.animate(withDuration: storyDuration) {
            currentProgress.setProgress(1.0, animated: true)
        }

        storyTimer = Timer.scheduledTimer(withTimeInterval: storyDuration, repeats: false) { [weak self] _ in
            self?.nextStory()
        }
        print("Stories: \(arrImgs.count), Progress bars: \(progressBars.count)")
    }

    func nextStory() {
        currentIndex += 1
        if currentIndex < arrImgs.count {
            showImage(at: currentIndex)
            animateProgressBar(at: currentIndex)
        } else {
            print("something wrong here")
            delegate?.didFinishStories(for: currentUserIndex)
        }
    }
}
extension StoryViewCell: UICollectionViewDataSource, UICollectionViewDelegate,UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        print(arrImgs.count)
        return arrImgs.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "SubStoriesCell", for: indexPath) as! SubStoriesCell
        cell.imgStory.image = arrImgs[indexPath.item]
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return cvSubStories.frame.size
    }
}

import UIKit

class StoryViewVC: UIViewController {
    //MARK: Outlet and Variable Declaration
    @IBOutlet weak var cvStory: UICollectionView!
    
    var currentUserIndex: Int = 0
    var stories: [UIImage] = []
    var storyDataa: [StoryData] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUP()
        let indexPath = IndexPath(item: currentUserIndex, section: 0)
        cvStory.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: false)
    }
}

//MARK: SetUp UI
extension StoryViewVC{
    func setUP(){
        let nibName = UINib(nibName: "StoryViewCell", bundle: nil)
        cvStory.register(nibName, forCellWithReuseIdentifier: "StoryViewCell")
    }
}
//MARK: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout
extension StoryViewVC: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return storyDataa[currentUserIndex].storyImage.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "StoryViewCell", for: indexPath) as! StoryViewCell
        let user = storyDataa[indexPath.item]
        cell.configure(with: user, userIndex: currentUserIndex)
        cell.delegate = self
     
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let height: CGFloat = UIScreen.main.bounds.size.height
        let width: CGFloat = UIScreen.main.bounds.size.width
        return CGSize(width: width, height: height)
    }
}
extension StoryViewVC: StoryViewCellDelegate {
    func didFinishStories(for userIndex: Int) {
        let nextIndex = userIndex + 1
        if nextIndex < storyDataa.count {
            currentUserIndex = nextIndex
            let indexPath = IndexPath(item: nextIndex, section: 0)
            
            // Scroll to next user
            cvStory.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: false)
            
            // 🔥 Force layout and configuration manually
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) { [weak self] in
                guard let self = self,
                      let cell = self.cvStory.cellForItem(at: indexPath) as? StoryViewCell else {
                    return
                }
                let user = self.storyDataa[nextIndex]
                cell.configure(with: user, userIndex: nextIndex)
                cell.delegate = self
            }
        } else {
            navigationController?.popToRootViewController(animated: true)
        }
    }
    
}

//MARK: Vlick Events
extension StoryViewVC{
    @IBAction func onClickBack(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
}
//bug fix
func nextStory() {
    // Prevent out-of-bounds crash
    guard currentIndex + 1 < arrImgs.count else {
        delegate?.didFinishStories(for: currentUserIndex)
        return
    }

    currentIndex += 1
    showImage(at: currentIndex)
    animateProgressBar(at: currentIndex)
}

func previousStory() {
    // Prevent out-of-bounds crash
    guard currentIndex - 1 >= 0 else {
        // Optional: Haptic feedback or UI feedback
        return
    }

    currentIndex -= 1
    resetProgressBars(from: currentIndex)
    showImage(at: currentIndex)
    animateProgressBar(at: currentIndex)
}
func showImage(at index: Int) {
    guard index >= 0 && index < arrImgs.count else { return }

    let indexPath = IndexPath(item: index, section: 0)
    cvSubStories.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: false)
}



protocol StoryViewCellDelegate: AnyObject {
    func didFinishStories(for userIndex: Int)
    func didRequestPreviousUser(from userIndex: Int)
}

func previousStory() {
    if currentIndex > 0 {
        currentIndex -= 1
        resetProgressBars(from: currentIndex)
        showImage(at: currentIndex)
        animateProgressBar(at: currentIndex)
    } else {
        // At the beginning of current user's stories
        delegate?.didRequestPreviousUser(from: currentUserIndex)
    }
}

func didRequestPreviousUser(from userIndex: Int) {
    let prevIndex = userIndex - 1
    if prevIndex >= 0 {
        currentUserIndex = prevIndex
        let indexPath = IndexPath(item: prevIndex, section: 0)

        cvStory.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: false)

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) { [weak self] in
            guard let self = self,
                  let cell = self.cvStory.cellForItem(at: indexPath) as? StoryViewCell else {
                return
            }
            let user = self.storyDataa[prevIndex]
            cell.configure(with: user, userIndex: prevIndex)
            cell.delegate = self
        }
    } else {
        // You may want to dismiss or loop around to the last user
        navigationController?.popToRootViewController(animated: true)
    }
}
