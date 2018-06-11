import Foundation

class HideMainWindow: Command {
    var messageOnError: String = Blackboard.shared.nextErrorMessage
        ?? "Failed to execute 'hide_main_window'."
    
    func execute(sender: NSObject) {
        NotificationCenter.default.post(name: Constants.HIDE_MAIN_WINDOW, object: nil)
    }
}
