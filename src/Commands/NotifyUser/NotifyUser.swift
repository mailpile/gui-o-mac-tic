import Foundation

class NotifyUser: Command {
    let message: String
    let popup: Bool
    
    init(messageToSend message: String, popup: Bool) {
        self.message = message
        self.popup = popup
    }
    
    func execute(sender: NSObject) {
        let strategy = NotificationStrategyFactory.build(preferPopup: self.popup)
        strategy.Notify(message: self.message)
    }
}
