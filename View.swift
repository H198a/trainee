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
