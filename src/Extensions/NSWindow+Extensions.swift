import Cocoa

extension NSWindow {
    /**
     Shakes the window back and forth, horizontally, `numberOfShakes` times over `duration`.
    */
    func shakeHorizontally(numberOfShakes: Int = 3,
                           vigour: CGFloat = CGFloat(0.04),
                           duration: TimeInterval = TimeInterval(0.3)) {
        let shakePath = CGMutablePath()
        shakePath.move(to: CGPoint(x:NSMinX(self.frame), y:NSMinY(self.frame)))
        for _ in 1...numberOfShakes {
            shakePath.addLine(to: CGPoint(x:NSMinX(self.frame) - self.frame.size.width * vigour, y:NSMinY(self.frame)))
            shakePath.addLine(to: CGPoint(x:NSMinX(self.frame) + self.frame.size.width * vigour, y:NSMinY(self.frame)))
        }
        shakePath.closeSubpath()
        
        let shakeAnimation = CAKeyframeAnimation()
        shakeAnimation.path = shakePath
        shakeAnimation.duration = duration
        
        let key = NSAnimatablePropertyKey.init("frameOrigin")
        self.animations = [key:shakeAnimation]
        self.animator().setFrameOrigin(self.frame.origin)
    }
}
