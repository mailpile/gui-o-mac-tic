import Foundation

class UserNotificationFacade {
    static func DeliverNotification(withTitle message: String) {
        let notification = NSUserNotification.init()
        notification.title = message
        
        NSUserNotificationCenter.default.deliver(notification)
    }
}
