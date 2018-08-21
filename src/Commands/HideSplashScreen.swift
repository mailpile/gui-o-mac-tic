import Foundation

class HideSplashScreen: Command {
    var messageOnError: String = Blackboard.shared.nextErrorMessage
        ?? "Failed to execute 'hide_splash_screen'."
    
    func execute(sender: NSObject) -> Bool {
        NotificationCenter.default.post(name: Constants.HIDE_SPLASH_SCREEN, object: nil)
        return true
    }
}
