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
