import Foundation

class SetNextErrorMessage: Command {
    var messageOnError: String = Blackboard.shared.nextErrorMessage
        ?? "Failed to execute 'set_next_error_message'."
    
    let message: String?
    
    init(_ message: String?) {
        self.message = message
    }
    
    func execute(sender: NSObject) {
        Blackboard.shared.nextErrorMessage = message
    }
}
