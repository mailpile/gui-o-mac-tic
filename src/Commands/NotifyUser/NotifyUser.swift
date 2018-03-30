import Foundation

class NotifyUser: Command {
    let message: String
    let popup: Bool
    let alert: Bool
    let actions: [ActionItem]?
    
    init(messageToSend message: String,
         preferUserNotificationCenter: Bool,
         alert: Bool,
         actions: [ActionItem]?) {
        self.message = message
        self.popup = preferUserNotificationCenter
        self.alert = alert
        self.actions = actions
    }
    
    func execute(sender: NSObject) {
        let strategy = NotificationStrategyFactory.build(preferUserNotificationCenter: self.popup, alert: self.alert)
        strategy.Notify(message: self.message)
        assertionFailure("Not yet implemented as it is unclear whether actions should be auto executed or user selectable.")
    }
}
