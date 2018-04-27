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
        // Note: executeSuccessfully will always be true if "command" is executed within a screen session.
        if !executedSuccesfully {
            // TODO Handle errors.
            assertionFailure("Not implemented.")
        }
    }
    
    private func execute(command: String!, terminalWindowTitle: String?, errorMessage: inout String) -> Bool {
        precondition(!command.isEmpty)
        let path = "PATH=\(Bundle.main.bundlePath)/Contents/Resources/app/bin:$PATH"
        
        let script: String =
        """
        tell application "Terminal"
            activate
            do script ""
            set window_id to id of first window whose frontmost is true
            set custom title of front window to "\(terminalWindowTitle ?? "My App")"
            do script "\(path)" in window id window_id of application "Terminal"
            do script "\(command!.replacingOccurrences(of: "\"", with: "\\\""))" in front window
        end tell
        """
        let appleScript = NSAppleScript.init(source: script)
        var errorInfo: NSDictionary?
        appleScript?.executeAndReturnError(&errorInfo)
        
        if errorInfo != nil {
            errorMessage = (String(describing: errorInfo))
        }
        return errorInfo == nil
    }
}
