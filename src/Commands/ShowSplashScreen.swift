import AppKit

class ShowSplashScreen: Command {
    var messageOnError: String = Blackboard.shared.nextErrorMessage
        ?? "Failed to execute 'show_splash_screen'."
    
    let background: NSImage?
    let message: String
    let showProgressBar: Bool
    let messageX: Float
    let messageY: Float
    
    init(background: NSImage?, message: String, showProgressBar: Bool, messageX: Float, messageY: Float) {
        self.background = background
        self.message = message
        self.showProgressBar = showProgressBar
        self.messageX = messageX
        self.messageY = messageY
    }
    
    func execute(sender: NSObject) -> Bool {
        var userInfo = [AnyHashable: Any]()
        userInfo["background"] = self.background
        userInfo["message"] = self.message
        userInfo["showProgressBar"] = self.showProgressBar
        userInfo["message_x"] = self.messageX
        userInfo["message_y"] = self.messageY
        NotificationCenter.default.post(name: Constants.SHOW_SPLASH_SCREEN,
                                        object: nil,
                                        userInfo: userInfo)
        return true
    }
}
