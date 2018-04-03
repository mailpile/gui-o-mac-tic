import Foundation

class NotifyBySplashScreenMessage: NotificationStrategy {
    static func Notify(message: String, actions: [ActionItem]?) {
        Blackboard.shared.splashMessages.push(message)
        NotificationCenter.default.post(name: Constants.SPLASH_SCREEN_NOTIFY_USER, object: nil)
    }
}
