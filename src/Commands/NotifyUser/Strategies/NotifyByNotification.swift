import Foundation

class NotifyByNotification: NotificationStrategy {
    static func Notify(message: String, actions: [ActionItem]?) {
        UserNotificationFacade.DeliverNotification(withText: message, withActions:actions)
    }
}
