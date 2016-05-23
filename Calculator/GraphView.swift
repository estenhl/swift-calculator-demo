import UIKit

@IBDesignable
class GraphView: UIView {
    @IBInspectable
    var scale: CGFloat = 1.0 { didSet { setNeedsDisplay() } }
    @IBInspectable
    var displacement = CGPoint(x: 0.0, y:0.0) { didSet { setNeedsDisplay() } }
    @IBInspectable
    private let units: CGFloat = 10
    @IBInspectable
    var axisColor: UIColor = UIColor.blueColor()
    @IBInspectable
    var expression: String? { didSet { setNeedsDisplay() } }
    
    func changeScale(recognizer: UIPinchGestureRecognizer) {
        switch recognizer.state {
        case .Changed, .Ended:
            scale *= recognizer.scale
            recognizer.scale = 1.0
        default: break
        }
    }
    
    func changeCenter(recognizer: UIPanGestureRecognizer) {
        switch recognizer.state {
        case .Changed, .Ended:
            let translation = recognizer.translationInView(self)
            displacement = CGPoint(x: displacement.x + translation.x, y: displacement.y + translation.y)
            recognizer.setTranslation(CGPoint(x: 0.0, y: 0.0), inView: self)
        default: break
        }
    }
    
    func focusOnAxisCenter(recognizer: UITapGestureRecognizer) {
        displacement = CGPoint(x: 0.0, y: 0.0)
    }
    
    private struct Ticks {
        static let Length: CGFloat = 5.0
        static let Width: CGFloat = 1.0
        enum Direction {
            case Vertical
            case Horizontal
        }
        var direction: Direction
        var increasing: Bool
        var scale: CGPoint
    }
    
    override func drawRect(rect: CGRect) {
        let center = CGPoint(x: bounds.midX + displacement.x, y: bounds.midY + displacement.y)
        let unitSize = min(bounds.maxX, bounds.maxY) / (units * scale)
        drawAxis(center, unitSize: unitSize)
        drawExpression()
        drawFunction(center, unitSize: unitSize, scope: findScope(center, unitSize: unitSize))
    }
    
    private func drawAxis(center: CGPoint, unitSize: CGFloat) {
        axisColor.set()
        straightPath(from: center, to: CGPoint(x: center.x, y: bounds.maxY), withTicks: Ticks(direction: .Vertical, increasing: true, scale: CGPoint(x: 0, y: unitSize))).stroke()
        straightPath(from: center, to: CGPoint(x: center.x, y: 0), withTicks: Ticks(direction: .Vertical, increasing: false, scale: CGPoint(x: 0, y: -unitSize))).stroke()
        straightPath(from: center, to: CGPoint(x: bounds.maxX, y: center.y), withTicks: Ticks(direction: .Horizontal, increasing: true, scale: CGPoint(x: unitSize, y: 0))).stroke()
        straightPath(from: center, to: CGPoint(x: 0, y: center.y), withTicks: Ticks(direction: .Horizontal, increasing: false, scale: CGPoint(x: -unitSize, y: 0))).stroke()
    }
    
    private func straightPath(from start: CGPoint, to end: CGPoint, withLineWidth lineWidth: CGFloat = 1.0, withTicks ticks: Ticks? = nil) -> UIBezierPath {
        let path = UIBezierPath()
        path.moveToPoint(start)
        path.addLineToPoint(end)
        path.lineWidth = lineWidth
        if ticks != nil {
            drawTicks(ticks!, from: start, to: end)
        }
        return path
    }
    
    private func drawTicks(ticks: Ticks, from start: CGPoint, to end: CGPoint) {
        var current = start
        // TODO
        var counter = 0
        while (((current.x < end.x) == ticks.increasing) || current.x == end.x) &&
            (((current.y < end.y) == ticks.increasing) || current.y == end.y) {
                var label: String? = nil
                if counter != 0 {
                    label = String(counter * (ticks.increasing ? 1 : -1))
                }
                tick(withCenter: current, withDirection: ticks.direction, withLabel: label).stroke()
                counter += 1
                current = CGPoint(x: current.x + ticks.scale.x, y: current.y + ticks.scale.y)
        }
    }
    
    private func tick(withCenter center: CGPoint, withDirection direction: Ticks.Direction, withLabel label: String? = nil) -> UIBezierPath {
        var path: UIBezierPath? = nil
        var labelPosition = CGPoint(x: center.x + CGFloat(3 * Ticks.Width), y: center.y)
        if direction == .Vertical {
            path = straightPath(from: CGPoint(x: center.x - CGFloat(Ticks.Length), y: center.y), to: CGPoint(x: center.x + CGFloat(Ticks.Length), y: center.y), withLineWidth: Ticks.Width, withTicks: nil)
        } else {
            labelPosition = CGPoint(x: center.x, y: center.y + CGFloat(2 * Ticks.Width))
            path = straightPath(from: CGPoint(x: center.x, y: center.y - CGFloat(Ticks.Length)), to: CGPoint(x: center.x, y: center.y + CGFloat(Ticks.Length)), withLineWidth: Ticks.Width, withTicks: nil)
        }
        if label != nil {
            let text: NSString = label!
            let attributes = [NSFontAttributeName: UIFont(name: "Helvetica Bold", size: 14.0)!, NSParagraphStyleAttributeName: NSMutableParagraphStyle()]
            text.drawWithRect(CGRect(x: labelPosition.x, y: labelPosition.y, width: 30, height: 30), options: .UsesLineFragmentOrigin, attributes: attributes, context: nil)
        }
        return path!
    }
    
    private func drawExpression() {
        if expression != nil {
            let text: NSString = expression!
            let attributes = [NSFontAttributeName: UIFont(name: "Helvetica Bold", size: 20.0)!, NSParagraphStyleAttributeName: NSMutableParagraphStyle()]
            text.drawWithRect(CGRect(x: bounds.minX + 10, y: bounds.minY + 10, width: 50, height: 50), options: .UsesLineFragmentOrigin, attributes: attributes, context: nil)
        }
    }
    
    private func findScope(center: CGPoint, unitSize: CGFloat) -> Range<Int> {
        let start = Float(-(center.x / unitSize + 1))
        let end = Float((bounds.maxX - center.x) / unitSize)
        return Int(start)...Int(ceilf(end))
    }
    
    private func drawFunction(center: CGPoint, unitSize: CGFloat, scope visibleValues: Range<Int>) {
        print("Start: \(visibleValues.startIndex), end: \(visibleValues.endIndex)")
        let path = UIBezierPath()
        path.moveToPoint(CGPoint(x: visibleValues.startIndex, y: visibleValues.startIndex^2))
        for i in visibleValues {
            path.addLineToPoint(CGPoint(x: translateValue(CGFloat(i), center: center.x, unitSize: unitSize), y: translateValue(CGFloat(pow(Double(i), 2.0)), center: center.y, unitSize: unitSize)))
        }
        UIColor.redColor().set()
        path.lineWidth = 2
        path.stroke()
    }
    
    private func translateValue(value: CGFloat, center: CGFloat, unitSize: CGFloat) -> CGFloat{
        return center + value * unitSize
    }
}
