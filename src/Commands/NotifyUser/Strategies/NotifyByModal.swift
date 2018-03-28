import AppKit

class NotifyByModal: NotificationStrategy {
    static func Notify(message: String) {
        Config.shared.mainWindowMessages.push(message)
        NotificationCenter.default.post(name: Constants.MAIN_WINDOW_NOTIFY_USER, object: nil)
    }
}
