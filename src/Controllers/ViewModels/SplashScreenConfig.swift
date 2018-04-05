import AppKit

@objc class SplashScreenConfig: NSObject {
    let message: String
    let background: NSImage
    let showProgressIndicator: Bool
    
    init(_ message: String, _ background: NSImage, _ showProgressIndicator: Bool) {
        self.message = message
        self.background = background
        self.showProgressIndicator = showProgressIndicator
    }
}
