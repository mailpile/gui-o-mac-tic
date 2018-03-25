import Foundation

class Shell: Command {
    let commands: [String]
    
    init(commands: [String]) {
        precondition(commands.count > 0, "Expected a command for execution.")
        self.commands = commands
    }
    
    func execute(sender: NSObject) {
        for command in commands {
            let task = Process()
            task.launchPath = "/usr/bin/env"
            task.arguments = command.components(separatedBy: .whitespaces)
            task.launch()
            task.waitUntilExit()
            if task.terminationStatus != EXIT_SUCCESS {
                // TODO error handling.
                assertionFailure("Not implemented.")
                return
            }
        }
    }
}
