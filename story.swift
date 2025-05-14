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
        cvStory.isPagingEnabled = true
        let indexPath = IndexPath(item: currentUserIndex, section: 0)
        DispatchQueue.main.async {
            self.cvStory.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: false)
        }
      
        let swipeGesture = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipe(_:)))
           swipeGesture.direction = .left // Swipe left to go to the next user
           view.addGestureRecognizer(swipeGesture)
        
        let swipeRightGesture = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipe(_:)))
         swipeRightGesture.direction = .right
         view.addGestureRecognizer(swipeRightGesture)
    }
    @objc func handleSwipe(_ gesture: UISwipeGestureRecognizer) {
        if gesture.direction == .left {
            navigateToNextUser()
        } else if gesture.direction == .right {
            navigateToPreviousUser()
        }
    }
}

//MARK: SetUp UI
extension StoryViewVC{
    func setUP(){
        let nibName = UINib(nibName: "StoryViewCell", bundle: nil)
        cvStory.register(nibName, forCellWithReuseIdentifier: "StoryViewCell")
    }
    func navigateToNextUser() {
           let nextUserIndex = currentUserIndex + 1
           if nextUserIndex < storyDataa.count {
               currentUserIndex = nextUserIndex
               let indexPath = IndexPath(item: currentUserIndex, section: 0)
               cvStory.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
               cvStory.reloadData() // Reload data to configure the new cell
           } else {
               // If at the last user, you might want to dismiss the story view
               navigationController?.popToRootViewController(animated: true)
               if let storyVC = self.navigationController?.viewControllers.first(where: { $0 is StoryVC }) as? StoryVC {
                   storyVC.cvStory.reloadData() // Update seen status in the main story list
               }
           }
       }
    func navigateToPreviousUser() {
            let previousUserIndex = currentUserIndex - 1
            if previousUserIndex >= 0 {
                currentUserIndex = previousUserIndex
                let indexPath = IndexPath(item: currentUserIndex, section: 0)
                cvStory.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
                cvStory.reloadData()
            } else {
                // If at the first user, you might want to do nothing or handle it differently
                // For instance, you could also pop the view controller here if going back from the first story makes sense in your UI.
                navigationController?.popToRootViewController(animated: true)
//                navigationController?.popViewController(animated: true)
                if let storyVC = self.navigationController?.viewControllers.first(where: { $0 is StoryVC }) as? StoryVC {
                    storyVC.cvStory.reloadData()
                }
            }
        }
}
//MARK: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout
extension StoryViewVC: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return storyDataa.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "StoryViewCell", for: indexPath) as! StoryViewCell
        let user = storyDataa[currentUserIndex]
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
        storyDataa[userIndex].isSeen = true
        arrStoryUsers[userIndex].isSeen = true
        
        let nextIndex = userIndex + 1
        if nextIndex < storyDataa.count {
            currentUserIndex = nextIndex
            cvStory.reloadData()
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                let indexPath = IndexPath(item: 0, section: 0)
                self.cvStory.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
                self.cvStory.reloadData()
            }
        } else {
            if let storyVC = self.navigationController?.viewControllers.first(where: { $0 is StoryVC }) as? StoryVC {
                storyVC.cvStory.reloadData()  //  will apply new border
            }
            navigationController?.popToRootViewController(animated: true)
        }
    }
    func didRequestPreviousUserStory(from userIndex: Int) {
        let previousIndex = userIndex - 1
        guard previousIndex >= 0 else {
            if let storyVC = self.navigationController?.viewControllers.first(where: { $0 is StoryVC }) as? StoryVC {
                        storyVC.cvStory.reloadData()
                    }
                    self.navigationController?.popToRootViewController(animated: true)
                    return
        }
        
        currentUserIndex = previousIndex
        cvStory.reloadData()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            let indexPath = IndexPath(item: 0, section: 0)
            self.cvStory.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: false)
            
            // Wait for cell to be rendered and then show the last story
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                if let cell = self.cvStory.cellForItem(at: indexPath) as? StoryViewCell {
                    cell.currentIndex = cell.arrImgs.count - 1
                    cell.showImage(at: cell.currentIndex)
                    cell.animateProgressBar(at: cell.currentIndex)
                }
            }
        }
    }
}

//MARK: Vlick Events
extension StoryViewVC{
    @IBAction func onClickBack(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
}


import UIKit

protocol StoryViewCellDelegate: AnyObject {
    func didFinishStories(for userIndex: Int)
    func didRequestPreviousUserStory(from userIndex: Int)
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
        storyTimer = nil
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        let nibName = UINib(nibName: "SubStoriesCell", bundle: nil)
        cvSubStories.register(nibName, forCellWithReuseIdentifier: "SubStoriesCell")
       
        cvSubStories.showsHorizontalScrollIndicator = false
        cvSubStories.translatesAutoresizingMaskIntoConstraints = false
        cvSubStories.layoutIfNeeded()
        cvSubStories.isPagingEnabled = true
//        cvSubStories.setContentOffset(.zero, animated: false)
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
        cvSubStories.setContentOffset(CGPoint(x: 0, y: 0), animated: false) // Reset sub-story position

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
        
        resetTimer()
        
        if isLeftSide {
            if currentIndex > 0 {
                previousStory()
            } else {
                delegate?.didRequestPreviousUserStory(from: currentUserIndex)
            }
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
        resetTimer()
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
    private func resetTimer() {
           storyTimer?.invalidate()
           storyTimer = nil
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
