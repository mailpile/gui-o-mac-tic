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
            assertionFailure("Intentionally not implemented. Executions errors are silent in production.")
        }
    }
    
    private func execute(command: String!, terminalWindowTitle: String?, errorMessage: inout String) -> Bool {
        precondition(!command.isEmpty)
        let path = "export PATH=\(Bundle.main.bundlePath)/Contents/Resources/app/bin:$PATH"
        let title = Bundle.main.infoDictionary![kCFBundleNameKey as String] as! String
        let template = Bundle.main.url(forResource: "Terminal", withExtension: "applescript")!
        var script = try! String(contentsOf: template)
        script = script.replacingOccurrences(of: "COMMAND_TOKEN",
                                             with:"\(path); \(command!)")
        script = script.replacingOccurrences(of: "TITLE_TOKEN", with: terminalWindowTitle ?? title)
        
        let appleScript = NSAppleScript.init(source: script)
        var errorInfo: NSDictionary?
        if let appleEventDescriptor = appleScript?.executeAndReturnError(&errorInfo) {
            Blackboard.shared.openedTerminalWindows.append(Int32.init(exactly: appleEventDescriptor.doubleValue)!)
        }
        
        if errorInfo != nil {
            errorMessage = (String(describing: errorInfo))
        }
        return errorInfo == nil
    }
}
