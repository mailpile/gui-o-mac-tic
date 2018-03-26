import Foundation

class UpdateSplashScreen: Command {
    let progress: Double?
    let message: String?
    
    init(_ progress: Double, _ message: String) {
        self.progress = progress
        self.message = message
    }
    
    func execute(sender: NSObject) {
        var userInfo = [AnyHashable: Any]()
        userInfo["progress"] = progress
        userInfo["message"] = message
        NotificationCenter.default.post(name: Constants.UPDATE_SPLASH_SCREEN,
                                        object: nil,
                                        userInfo: userInfo)
    }
    
    
}
