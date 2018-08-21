import Foundation

class UpdateSplashScreen: Command {
    var messageOnError: String = Blackboard.shared.nextErrorMessage
        ?? "Failed to execute 'update_splash_screen'."
    
    let progress: Double?
    let message: String?
    
    init(_ progress: Double, _ message: String) {
        self.progress = progress
        self.message = message
    }
    
    func execute(sender: NSObject) -> Bool {
        var userInfo = [AnyHashable: Any]()
        userInfo["progress"] = progress
        userInfo["message"] = message
        NotificationCenter.default.post(name: Constants.UPDATE_SPLASH_SCREEN,
                                        object: nil,
                                        userInfo: userInfo)
        return true
    }
}
