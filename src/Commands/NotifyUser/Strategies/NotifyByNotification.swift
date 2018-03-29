import Foundation

class NotifyByNotification: NotificationStrategy {
    static func Notify(message: String) {
        UserNotificationFacade.DeliverNotification(withText: message)
    }
}
