import Foundation

class SetNextErrorMessage: Command {
    let message: String?
    
    init(_ message: String?) {
        self.message = message
    }
    
    func execute(sender: NSObject) {
        Config.shared.nextErrorMessage = message
    }
}
