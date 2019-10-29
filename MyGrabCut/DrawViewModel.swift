import UIKit

class DrawViewModel: NSObject {
    var color: UIColor!
    var path: UIBezierPath!
    var width: CGFloat = 0.0

    convenience init(color: UIColor?, path: UIBezierPath?, width: CGFloat) {
        self.init()
        self.color = color
        self.path = path
        self.width = width
    }
}
