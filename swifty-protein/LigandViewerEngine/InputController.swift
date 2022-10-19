import Foundation
import GameController

class InputController {
    
    var leftMouseDown = false
    var mouseDelta = Point.zero
    var mouseScroll = Point.zero
    var touchLocation: CGPoint?
    var xFromTouch =  CGFloat(1)
    var yFromTouch = CGFloat(1)
    var touchDelta: CGSize? {
        didSet {
            touchDelta?.height *= -1
            if let delta = touchDelta {
                mouseDelta = Point(x: Float(delta.width), y: Float(delta.height))
            }
            leftMouseDown = touchDelta != nil
        }
    }
    static let shared = InputController()
    private init() {
//        let center = NotificationCenter.default
    }
}

struct Point {
    var x: Float
    var y: Float
    static let zero = Point(x: 0, y: 0)
}
