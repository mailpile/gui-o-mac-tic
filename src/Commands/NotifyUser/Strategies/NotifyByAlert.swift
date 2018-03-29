import AppKit

class NotifyByAlert: NotificationStrategy {
    static func Notify(message: String) {
        let appName = Bundle.main.infoDictionary![kCFBundleNameKey as String] as! String
        UserNotificationFacade.DeliverNotification(withTitle: "Alert from \(appName)", withText: message)
        
        func showAlert() {
            let alert = NSAlert()
            alert.messageText = "Alert from \(appName)"
            alert.informativeText = message
            alert.addButton(withTitle: "OK")
            alert.alertStyle = NSAlert.Style.warning
            alert.runModal()
        }
        showAlert()
        
        NSApp.requestUserAttention(.criticalRequest)
    }
}
