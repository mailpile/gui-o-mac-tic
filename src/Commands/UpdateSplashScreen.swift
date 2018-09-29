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
        if let config = Blackboard.shared.splashScreenConfig {
            if let message = self.message {
                config.message = message
            }
            if let progress = self.progress {
                config.progress = progress
            }
            NotificationCenter.default.post(name: Constants.UPDATE_SPLASH_SCREEN,
                                            object: nil,
                                            userInfo: nil)
        }
        
        return true
    }
}
