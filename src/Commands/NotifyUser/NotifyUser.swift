import Foundation

class NotifyUser: Command {
    let message: String
    let popup: Bool
    let alert: Bool
    
    init(messageToSend message: String, preferUserNotificationCenter: Bool, alert: Bool) {
        self.message = message
        self.popup = preferUserNotificationCenter
        self.alert = alert
    }
    
    func execute(sender: NSObject) {
        let strategy = NotificationStrategyFactory.build(preferUserNotificationCenter: self.popup, alert: self.alert)
        strategy.Notify(message: self.message)
    }
}
