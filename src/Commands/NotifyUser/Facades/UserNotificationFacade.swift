import Foundation

class UserNotificationFacade {
    static func DeliverNotification(withTitle title: String? = nil, withText text: String) {
        let notification = buildNotification(withTitle: title, withText: text)
        NSUserNotificationCenter.default.deliver(notification)
    }
    
    static func DeliverNotification(withTitle title: String? = nil, withText text: String, withActions actions: [ActionItem]?) {
        let notification = buildNotification(withTitle: title, withText: text)
        
        switch actions?.count ?? 0 {
        case let value where (value == Int.max) || (2..<Int.max ~= value):
            var additionalActions = [NSUserNotificationAction]()
            for i in stride(from: 1, to: value, by: 1) {
                let action = NSUserNotificationAction(identifier: actions![i].id, title: actions![i].label)
                additionalActions.append(action)
            }
            notification.additionalActions = additionalActions
            fallthrough
        case 1:
            notification.hasActionButton = true
            notification.actionButtonTitle = actions!.first!.label!
        
        case 0:
            notification.hasActionButton = false
            
        default:
            preconditionFailure("Execution reached a point which shall be unreachable.")
        }
        NSUserNotificationCenter.default.deliver(notification)
    }
    
    static private func buildNotification(withTitle title: String? = nil, withText text: String) -> NSUserNotification {
        let notification = NSUserNotification()
        let appName = (Bundle.main.infoDictionary![kCFBundleNameKey as String] as! String)
        notification.title = title ?? appName
        notification.informativeText = text
        return notification
    }
}
