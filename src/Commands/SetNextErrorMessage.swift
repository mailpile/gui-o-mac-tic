import Foundation

class SetNextErrorMessage: Command {
    let message: String?
    
    init(_ message: String?) {
        self.message = message
    }
    
    func execute(sender: NSObject) {
        Blackboard.shared.nextErrorMessage = message
    }
}
