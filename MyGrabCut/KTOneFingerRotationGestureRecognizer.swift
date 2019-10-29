
import UIKit

class KTOneFingerRotationGestureRecognizer: UIGestureRecognizer {
    var rotation: Float = 0
    // @synthesize rotation = rotation_;
    // @synthesize rotation = rotation_;
    override func touchesBegan(_ touches: Set<UITouch>, with _: UIEvent) {
        // Fail when more than 1 finger detected.
        if touches.count > 1 {
            state = .failed
        }
    }

    override func touchesMoved(_ touches: Set<UITouch>, with _: UIEvent) {
        if state == .possible {
            state = .began
        } else {
            state = .changed
        }

        // We can look at any touch object since we know we
        // have only 1. If there were more than 1 then
        // touchesBegan:withEvent: would have failed the recognizer.
        let touch = touches.first

        // To rotate with one finger, we simulate a second finger.
        // The second figure is on the opposite side of the virtual
        // circle that represents the rotation gesture.

        guard let view = self.view else { return }
        let center = CGPoint(x: view.bounds.midX, y: view.bounds.midY)
        let currentTouchPoint = touch?.location(in: view) ?? .zero
        let previousTouchPoint = touch?.previousLocation(in: view) ?? .zero

        let value2 = Float(currentTouchPoint.x - center.x) - atan2f(Float(previousTouchPoint.y - center.y), Float(previousTouchPoint.x - center.x))

        let angleInRadians = atan2f(Float(currentTouchPoint.y - center.y), value2)

        rotation = angleInRadians
        // [self setRotation:angleInRadians];
    }

    override func touchesEnded(_: Set<UITouch>, with _: UIEvent) {
        // Perform final check to make sure a tap was not misinterpreted.
        if state == .changed {
            state = .ended
        } else {
            state = .failed
        }
    }

    override func touchesCancelled(_: Set<UITouch>, with _: UIEvent) {
        state = .failed
    }
}
