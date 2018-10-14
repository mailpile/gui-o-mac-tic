import AppKit

@objc class SplashScreenConfig: NSObject {
    var message: String
    var background: NSImage
    var showProgressIndicator: Bool
    var messageX: Float
    var messageY: Float
    var progress: Double = 0.0
    
    init(_ message: String, _ background: NSImage, _ showProgressIndicator: Bool, _ messageX: Float, _ messageY: Float) {
        self.message = message
        self.background = background
        self.showProgressIndicator = showProgressIndicator
        precondition(messageX >= 0.0 && messageY >= 0.0 && messageX <= 1.0 && messageY <= 1.0)
        self.messageX = messageX
        self.messageY = messageY
    }
}
