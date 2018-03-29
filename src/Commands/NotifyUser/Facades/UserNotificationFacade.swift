import Foundation

class UserNotificationFacade {
    static func DeliverNotification(withTitle title: String? = nil, withText text: String) {
        let notification = NSUserNotification()
        
        let appName = (Bundle.main.infoDictionary![kCFBundleNameKey as String] as! String)
        notification.title = title ?? appName
        notification.informativeText = text
        
        NSUserNotificationCenter.default.deliver(notification)
    }
}
