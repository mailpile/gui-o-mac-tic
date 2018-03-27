import AppKit

class ShowSplashScreen: Command {
    let background: NSImage?
    let message: String
    let showProgressBar: Bool
    
    init(background: NSImage?, message: String, showProgressBar: Bool) {
        self.background = background
        self.message = message
        self.showProgressBar = showProgressBar
    }
    
    func execute(sender: NSObject) {
        var userInfo = [AnyHashable: Any]()
        userInfo["background"] = background
        userInfo["message"] = message
        userInfo["showProgressBar"] = showProgressBar
        NotificationCenter.default.post(name: Constants.SHOW_SPLASH_SCREEN,
                                        object: nil,
                                        userInfo: userInfo)
    }
}
