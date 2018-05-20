import AppKit

class Quit: Command {
    var messageOnError: String = Blackboard.shared.nextErrorMessage
        ?? "Failed to execute 'quit'."
    
    @objc func execute(sender: NSObject) {
        NSApplication.shared.terminate(self)
        /* TODO error handling. If execution reaches this point, then the application could not be terminated. */
        assertionFailure("Not implemented.")
    }
}
