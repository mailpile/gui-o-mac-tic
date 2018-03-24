import Foundation

final class Terminal {
    private init() {
    }
    
    static func execute(command: String!, terminalWindowTitle: String?) {
        assert(!command.isEmpty)
        
        /* The empty lines and the indentation is part of the AppleScript syntax. */
        let headerPart: String =
        """
        tell application "Terminal"
            do script " "

        """
        /* The empty line and the indentation is part of the AppleScript syntax. */
        let titlePart: String =
        """
            set custom title of tab 1 of front window to "\(terminalWindowTitle!)"
        
        """
        /* The indentation is part of the AppleScript syntax. */
        let executionPart: String =
        """
            do script "\(command!)" in front window
        end tell
        """
        
        let script = headerPart
            + (terminalWindowTitle != nil ? titlePart : "")
            + executionPart
        
        let appleScript = NSAppleScript.init(source: script)
        appleScript?.executeAndReturnError(nil)
    }
}
