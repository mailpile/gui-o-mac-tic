import Foundation
import Cocoa

class NotifyUser: Command {
    var messageOnError: String = Blackboard.shared.nextErrorMessage
        ?? "Failed to execute 'notify_user'."
    
    let message: String
    let popup: Bool
    let alert: Bool
    let actions: [ActionItem]?
    
    init(messageToSend message: String,
         popup: Bool,
         alert: Bool,
         actions: [ActionItem]?) {
        self.message = message
        self.popup = popup
        self.alert = alert
        self.actions = actions
    }
    
    func execute(sender: NSObject) -> Bool {
        Blackboard.shared.notification = self.message
        if self.popup {
            UserNotificationFacade.DeliverNotification(withText: message, withActions:actions)
        }
        if self.alert {
            NSApp.requestUserAttention(.criticalRequest)
            for window in NSApp.windows {
                window.shakeHorizontally()
            }
        }
        return true
    }
}
