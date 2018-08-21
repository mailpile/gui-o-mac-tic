import AppKit

/**
 Executes a command, then listens to it's stdout.
 */
class Listener: Thread {
    /** The command this listener is to listen to. */
    var command: String?
    /** The command's arguments. */
    var arguments = [String]()
    
    func listen() {
        /**
         Executes a shell command, parses it's output.
         */
        func execute() {
            let process = Process()
            let binary = "/usr/bin/env"
            
            if #available(OSX 10.13, *) {
                process.executableURL = URL(fileURLWithPath: binary)
            } else {
                process.launchPath = binary
            }
            process.arguments = self.arguments
            
            let stdout = Pipe()
            let stdoutHandle = stdout.fileHandleForReading
            stdoutHandle.waitForDataInBackgroundAndNotify()
            process.standardOutput = stdout
            
            NotificationCenter.default.addObserver(forName: NSNotification.Name.NSFileHandleDataAvailable,
                                                   object: stdoutHandle,
                                                   queue: nil) { notification -> Void in
                                                    let data = stdoutHandle.availableData
                                                    if data.count > 0 {
                                                        if let str = NSString(data: data,
                                                                              encoding: String.Encoding.utf8.rawValue) {
                                                            let commands = str.components(separatedBy: CharacterSet.newlines)
                                                            for command in commands {
                                                                self.handleGUIOMacTicCommand(command: command as String)
                                                            }
                                                        }
                                                        stdoutHandle.waitForDataInBackgroundAndNotify()
                                                    }
            }
            
            process.launch()
            process.waitUntilExit()
            
            if process.terminationStatus != 0 {
                DispatchQueue.main.async {
                    let errorMsg = "The app can not be configured because of an error from OK LISTEN TO."
                    ErrorNotifier.displayErrorToUser(preferredErrorMessage: errorMsg)
                }
            }
        }
        
        self.arguments.append("-S") // Passes -S to env.
        self.arguments.append(self.command!)
        
        execute()
    }
    
    func handleGUIOMacTicCommand(command: String) {
        /* Parse the gui-o-matic command */
        do {
            let cmd = try? Parser.guiomaticCommandToOperationAndArgs(guiomaticCommand: command)
            guard cmd != nil else { return }
            if (cmd!.op == Operation.show_main_window) {
                Blackboard.shared.canMainWindowBeVisible = true
            } else if (cmd!.op == Operation.hide_main_window) {
                Blackboard.shared.canMainWindowBeVisible = false
            }
            let command = CommandFactory.build(forOperation: cmd!.op, withArgs: cmd!.args)
            
            /* Dispatch the command for execution on the GUI thread. */
            DispatchQueue.main.async {
                _ = command.execute(sender: self)
            }
        }
    }
    
}
