import Foundation

class NotifyUser: Command {
    let message: String
    let popup: Bool
    
    init(messageToSend message: String, preferUserNotificationCenter: Bool) {
        self.message = message
        self.popup = preferUserNotificationCenter
    }
    
    func execute(sender: NSObject) {
        let strategy = NotificationStrategyFactory.build(preferUserNotificationCenter: self.popup)
        strategy.Notify(message: self.message)
    }
}
