import AppKit

class Terminal: Command {
    let command: String
    let title: String?
    let icon: String? // TODO What should be done with this icon?
    
    init(_ command: String, _ title: String? = nil, _ icon: String? = nil) {
        precondition(command.count > 0, "Expected a command for execution.")
        self.command = command
        self.title = title
        self.icon = icon
    }
    
    func execute(sender: NSObject) {
        var errorMessage: String = ""
        let executedSuccesfully = execute(command: command, terminalWindowTitle: title, errorMessage: &errorMessage)
        if !executedSuccesfully {
            // TODO Handle errors.
            assertionFailure("Not implemented.")
        }
    }
    
    private func execute(command: String!, terminalWindowTitle: String?, errorMessage: inout String) -> Bool {
        precondition(!command.isEmpty)
        
        /* The empty lines and the indentation is part of the AppleScript syntax. */
        let headerPart: String =
        """
        tell application "Terminal"
            do script " "

        """
        /* The empty line and the indentation is part of the AppleScript syntax. */
        let titlePart: String =
        """
            set custom title of tab 1 of front window to "\(terminalWindowTitle ?? "My App")"
        
        """
        /* The indentation is part of the AppleScript syntax. */
        let executionPart: String =
        """
            do script "\(command!.replacingOccurrences(of: "\"", with: "\\\""))" in front window
        end tell
        """
        
        let script = headerPart
            + (terminalWindowTitle != nil ? titlePart : "")
            + executionPart
        
        let appleScript = NSAppleScript.init(source: script)
        var errorInfo: NSDictionary?
        appleScript?.executeAndReturnError(&errorInfo)
        
        if errorInfo != nil {
            errorMessage = (String(describing: errorInfo))
        }
        return errorInfo == nil
    }
}
