import Foundation

class HideSplashScreen: Command {
    func execute(sender: NSObject) {
        NotificationCenter.default.post(name: Constants.HIDE_SPLASH_SCREEN, object: nil)
    }
}
