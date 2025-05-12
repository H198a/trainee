view.
import UIKit

class DrawingView: UIView {

    private var lines: [Line] = []
    private var currentLine: Line?

    var strokeColor: UIColor = .red
    var lineWidth: CGFloat = 3.0

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let point = touches.first?.location(in: self) else { return }
        currentLine = Line(points: [point], color: strokeColor, width: lineWidth)
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let point = touches.first?.location(in: self),
              var current = currentLine else { return }

        current.points.append(point)
        currentLine = current
        lines.append(current)
        setNeedsDisplay()
    }

    override func draw(_ rect: CGRect) {
        guard let context = UIGraphicsGetCurrentContext() else { return }

        for line in lines {
            context.setStrokeColor(line.color.cgColor)
            context.setLineWidth(line.width)
            context.setLineCap(.round)

            for (i, point) in line.points.enumerated() {
                if i == 0 {
                    context.move(to: point)
                } else {
                    context.addLine(to: point)
                }
            }

            context.strokePath()
        }
    }

    func clear() {
        lines.removeAll()
        setNeedsDisplay()
    }

    func getImageOverlay(on image: UIImage?) -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(bounds.size, false, 0)
        image?.draw(in: bounds)
        draw(bounds)
        let finalImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return finalImage
    }
}

struct Line {
    var points: [CGPoint]
    var color: UIColor
    var width: CGFloat
}
@IBOutlet weak var drawingView: DrawingView!

override func viewDidLoad() {
    super.viewDidLoad()
    drawingView.backgroundColor = .clear
}



func imageFrameInImageView(_ imageView: UIImageView) -> CGRect {
    guard let image = imageView.image else { return .zero }

    let imageRatio = image.size.width / image.size.height
    let viewRatio = imageView.frame.width / imageView.frame.height

    if imageRatio > viewRatio {
        // Image is wider
        let width = imageView.frame.width
        let height = width / imageRatio
        let y = (imageView.frame.height - height) / 2
        return CGRect(x: 0, y: y, width: width, height: height)
    } else {
        // Image is taller
        let height = imageView.frame.height
        let width = height * imageRatio
        let x = (imageView.frame.width - width) / 2
        return CGRect(x: x, y: 0, width: width, height: height)
    }
}
override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()

    // Align drawingView exactly on top of the image area
    let imageFrame = imageFrameInImageView(drawingImg)
    drawingView.frame = imageFrame
}




import UIKit

class ReelsVC: UIViewController {
//MARK: Outlet and Variable Declaration
    @IBOutlet weak var tblReels: UITableView!
    
    var arrImgs: [String] = ["img1","img2","img3","img4","img5","img6"]
    override func viewDidLoad() {
        super.viewDidLoad()
        setUP()
    }
}
//MARK: Setup UI
extension ReelsVC{
    func setUP(){
        let nibName = UINib(nibName: "ReelsCell", bundle: nil)
        tblReels.register(nibName, forCellReuseIdentifier: "ReelsCell")
    }
}
//MARK: UITableViewDataSource, UITableViewDelegate
extension ReelsVC: UITableViewDataSource, UITableViewDelegate{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrImgs.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ReelsCell", for: indexPath) as! ReelsCell
        cell.imgReels.image = UIImage(named: arrImgs[indexPath.row])
        return cell
    }
}




import UIKit
import AVFoundation

class ReelsCell: UITableViewCell {
//MARK: Outlet and Variable Declaration
    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var imgReels: UIImageView!
    
    private var player: AVPlayer?
    private var playerLayer: AVPlayerLayer?
    private var videoURL: URL?
    private var playerLooperObserver: NSObjectProtocol?

    override func prepareForReuse() {
        super.prepareForReuse()
        player?.play()
    }

    func configure(with urlStr: String) {
        guard let url = URL(string: urlStr) else { return }
        if url != videoURL {
            pauseVideo() // clean up old player if URL has changed
            videoURL = url
        }
//        pauseVideo()
        player = AVPlayer(url: url)
        player?.isMuted = true

        // Add looping behavior
        addLoopObserver()
//        playerLayer?.removeFromSuperlayer() // remove old layer before adding a new one
        playerLayer = AVPlayerLayer(player: player)
        playerLayer?.frame = contentView.bounds
        playerLayer?.videoGravity = .resizeAspectFill
        player?.volume = 2

        if let layer = playerLayer {
            contentView.layer.addSublayer(layer)
        }
    }

    func playVideo() {
        print("playing video for URL: \(String(describing: videoURL))")
        player?.isMuted = false
        player?.play()
    }

    func pauseVideo() {
        print("pause video called.....-------")
        player?.pause()
        player?.replaceCurrentItem(with: nil)
        playerLayer?.removeFromSuperlayer()
        player = nil
        playerLayer = nil

        // remove observer
        if let observer = playerLooperObserver {
            NotificationCenter.default.removeObserver(observer)
            playerLooperObserver = nil
        }
    }

    private func addLoopObserver() {
        guard let player = player else { return }

        playerLooperObserver = NotificationCenter.default.addObserver(
            forName: .AVPlayerItemDidPlayToEndTime,
            object: player.currentItem,
            queue: .main
        ) { [weak self] _ in
            self?.player?.seek(to: .zero)
            self?.player?.play()
        }
    }
}


import UIKit
import AVFoundation
import SwiftLoader

class ReelsVC: UIViewController {
    //MARK: Outlet and Variable Declaration
    @IBOutlet weak var tblReels: UITableView!
    var currentlyPlayingCell: ReelsCell?

    var arrVideoUrl: [String] = [
        "https://videos.pexels.com/video-files/1578318/1578318-hd_1920_1080_30fps.mp4",
        "https://videos.pexels.com/video-files/5580492/5580492-sd_360_640_30fps.mp4",
        "https://videos.pexels.com/video-files/3468587/3468587-sd_360_640_30fps.mp4",
        "https://videos.pexels.com/video-files/5580492/5580492-sd_360_640_30fps.mp4",
        "https://videos.pexels.com/video-files/3468587/3468587-sd_360_640_30fps.mp4",
        "https://videos.pexels.com/video-files/3468587/3468587-sd_360_640_30fps.mp4",
        "https://videos.pexels.com/video-files/4434150/4434150-sd_360_640_30fps.mp4",
        "https://videos.pexels.com/video-files/3468587/3468587-sd_360_640_30fps.mp4",
        "https://videos.pexels.com/video-files/3343679/3343679-sd_640_360_30fps.mp4",
        "https://videos.pexels.com/video-files/1578318/1578318-hd_1920_1080_30fps.mp4"
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUP()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        playVisibleVideo()
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        playVisibleVideo()
    }
}
//MARK: Setup UI
extension ReelsVC{
    func setUP(){
        let nibName = UINib(nibName: "ReelsCell", bundle: nil)
        tblReels.register(nibName, forCellReuseIdentifier: "ReelsCell")
        tblReels.isUserInteractionEnabled = true
    }
}
//MARK: Custom Functions
extension ReelsVC{
    func playVisibleVideo() {
        let visibleRect = CGRect(origin: tblReels.contentOffset, size: tblReels.bounds.size)
        let visiblePoint = CGPoint(x: visibleRect.midX, y: visibleRect.midY)

        guard let indexPath = tblReels.indexPathForRow(at: visiblePoint),
              let cell = tblReels.cellForRow(at: indexPath) as? ReelsCell else { return }

        if currentlyPlayingCell !== cell {
            currentlyPlayingCell?.pauseVideo()
            currentlyPlayingCell = cell
            cell.playVideo()
        } else {
            // force replay if needed (in case reused cell didn't play)
//            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
//            currentlyPlayingCell?.playVideo()
//                currentlyPlayingCell = cell
            cell.playVideo()
//            }
        }
    }


}
//MARK: UITableViewDataSource, UITableViewDelegate
extension ReelsVC: UITableViewDataSource, UITableViewDelegate{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        SwiftLoader.show(title: "Loading", animated: true)
        return arrVideoUrl.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        SwiftLoader.hide()
        let cell = tableView.dequeueReusableCell(withIdentifier: "ReelsCell", for: indexPath) as! ReelsCell
        cell.configure(with: arrVideoUrl[indexPath.row])
        
//        let visibleRect = CGRect(origin: tableView.contentOffset, size: tableView.bounds.size)
//        let visiblePoint = CGPoint(x: visibleRect.midX, y: visibleRect.midY)
//        if let visibleIndexPath = tableView.indexPathForRow(at: visiblePoint), visibleIndexPath == indexPath{
//            cell.playVideo()
//        }
        return cell
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return tblReels.frame.height
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        self.playVisibleVideo()
    }
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        self.playVisibleVideo()
    }
}

