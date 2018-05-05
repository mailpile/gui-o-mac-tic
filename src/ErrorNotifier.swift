import AppKit

class ErrorNotifier {
    static func displayErrorToUser(preferredErrorMessage: String) {
        DispatchQueue.main.async {
            func showAlert() {
                let alert = NSAlert()
                if let error = Blackboard.shared.nextErrorMessage {
                    Blackboard.shared.nextErrorMessage = nil
                    alert.messageText = error
                } else {
                    alert.messageText = "Error"
                }
                alert.informativeText = preferredErrorMessage
                alert.addButton(withTitle: "Exit")
                alert.alertStyle = NSAlert.Style.critical
                alert.runModal()
                NSApp.terminate(self)
            }
            showAlert()
            NSApp.requestUserAttention(.criticalRequest)
        }
    }
}
