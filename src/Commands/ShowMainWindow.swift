import Foundation
class ShowMainWindow: Command {
    var messageOnError: String = Blackboard.shared.nextErrorMessage
        ?? "Failed to execute 'show_main_window'."
    
    func execute(sender: NSObject) -> Bool {
        NotificationCenter.default.post(name: Constants.SHOW_MAIN_WINDOW, object: nil)
        return true
    }
}
