import Cocoa

var server = Server()

func guiomaticCommandToOperationAndArgs(guiomaticCommand: String) -> (op: Operation, args: Args) {
    let keyValuePair = guiomaticCommand.split(separator: " ", maxSplits: 1)
    let key = String(keyValuePair[0])
    let op = StringToOperationMapper.Map(operation: key)
    let value = String(keyValuePair[1])
    
    do {
        let data = value.data(using: .utf8)
        let argsJSON: [String: Any]
        try argsJSON = JSONSerialization.jsonObject(with: data!, options: []) as! [String: Any]
        let args = Args(string: nil, list: nil, dictionary: argsJSON)
        return (op: op!, args: args)
    } catch {
        print(error) // TODO error handling.
        preconditionFailure("Not implemented.")
    }
}

let OK_LISTEN_TO = "OK LISTEN TO:"
let OK_LISTEN_HTTP = "OK LISTEN HTTP:"
let OK_LISTEN_TCP = "OK LISTEN TCP:"
let OK_GO = "OK GO"
let OK_LISTEN = "OK LISTEN"
let PORT = "%PORT%"
let app: NSApplication
let appDelegate: AppDelegate
do {
    /** Begin Stage 1 **/
    let boot = Boot()
    boot.boot()
    try Blackboard.shared.config = Parser.parse(json: boot.part1!)
    /** End of Stage 1 **/
    
    /** Set app icon and start the main app thread. */
    if let appIconPath = Blackboard.shared.config?.app_icon,
        let appIcon = NSImage(contentsOfFile: appIconPath) {
        NSWorkspace.shared.setIcon(appIcon, forFile: Bundle.main.bundlePath, options: [])
    }
    app = NSApplication.shared
    appDelegate = AppDelegate()
    app.delegate = appDelegate
    /** Main thread is now running. */
    
    /** Begin Stage 2 **/
    for rawStage2Command: String in boot.part2 {
        func stage2(command: String) -> Bool /* true if for loop should is allowed to run again */ {
            guard rawStage2Command.isEmpty == false else {
                return true
            }
            
            switch rawStage2Command {
            case OK_GO:
                return false
            
            case let command where command.hasPrefix(OK_LISTEN_TO):
                preconditionFailure("Not yet implemented.")
            
            case let command where command.hasPrefix(OK_LISTEN_TCP):
                /*
                 * NOTE Starts a server for listening to commands over TCP,
                 * which then executes a shell command which triggres commands to
                 * be send over TCP.
                 */
                DispatchQueue.global(qos: .background).async {
                    server.serve() {
                        var shellCommand = String(command.dropFirst(OK_LISTEN_TCP.count))
                        shellCommand = shellCommand.trimmingCharacters(in: .whitespaces)
                        shellCommand = shellCommand.replacingOccurrences(of: PORT, with: String(Blackboard.shared.tcp_port!))
                        let shell = Terminal(shellCommand)
                        shell.execute(sender: NSObject()/* Not sent by an object. */)
                    }
                }
                
            case let command where command.hasPrefix(OK_LISTEN_HTTP):
                /*
                 * NOTE Starts a server for listening to commands over TCP,
                 * then requests commands to be send over TCP.
                 */
                DispatchQueue.global(qos: .background).async {
                    server.serve() {
                        do {
                            var uri = String(command.dropFirst(OK_LISTEN_HTTP.count))
                            uri = uri.trimmingCharacters(in: .whitespaces)
                            uri = uri.replacingOccurrences(of: PORT, with: String(Blackboard.shared.tcp_port!))
                            let url = URL(string: uri)
                            try _ = String(contentsOf: url!, encoding: String.Encoding.utf8)
                        } catch {
                            // TODO error handling, server could not be contacted.
                            print("Failed to connect to url")
                            preconditionFailure("not yet implemented.")
                        }
                    }
                }
                
            case OK_LISTEN:
                return true
            
            default:
                let cmd = guiomaticCommandToOperationAndArgs(guiomaticCommand: rawStage2Command)
                let command = CommandFactory.build(forOperation: cmd.op, withArgs: cmd.args)
                Blackboard.shared.unexecuted.push(command)
            }
            return true
        }
        if stage2(command: rawStage2Command) == false { // NOTE Possible recursion.
            break
        }
    }
    /** End of stage 2 **/
}
catch {
    print(error) // TODO Error handling.
    exit(EX_USAGE)
}

_ = NSApplicationMain(CommandLine.argc, CommandLine.unsafeArgv)
