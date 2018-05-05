import Cocoa

var server = Server()

let OK_LISTEN_TO = "OK LISTEN TO:"
let OK_LISTEN_HTTP = "OK LISTEN HTTP:"
let OK_LISTEN_TCP = "OK LISTEN TCP:"
let OK_GO = "OK GO"
let OK_LISTEN = "OK LISTEN"
let PORT = "%PORT%"
let app: NSApplication
let appDelegate: AppDelegate

func runStage1(_ boot: Boot) throws {
    try boot.boot()
    try Blackboard.shared.config = Parser.parse(json: boot.stage1!)
    Blackboard.shared.canMainWindowBeVisible = Blackboard.shared.config?.main_window?.show ?? false
}

func runStage2(_ boot: Boot) {
    for rawStage2Command: String in boot.stage2 {
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
                 * which then executes a shell command which triggers commands to
                 * be send over TCP.
                 */
                server.serve() {
                    var shellCommand = String(command.dropFirst(OK_LISTEN_TCP.count))
                    shellCommand = shellCommand.trimmingCharacters(in: .whitespaces)
                    shellCommand = shellCommand.replacingOccurrences(of: PORT, with: String(Blackboard.shared.tcp_port!))
                    #if DEBUG
                    print("DEBUG-mode: Replacing Shell command with Terminal command.")
                    let shell = Terminal(shellCommand)
                    #else
                    var commands = [String]()
                    commands.append(shellCommand)
                    let shell = Shell(commands)
                    #endif
                    shell.execute(sender: NSObject()/* Not sent by an object. */)
                }
                
            case let command where command.hasPrefix(OK_LISTEN_HTTP):
                /*
                 * NOTE Starts a server for listening to commands over TCP,
                 * then requests commands to be send over TCP.
                 */
                server.serve() {
                    do {
                        var uri = String(command.dropFirst(OK_LISTEN_HTTP.count))
                        uri = uri.trimmingCharacters(in: .whitespaces)
                        uri = uri.replacingOccurrences(of: PORT, with: String(Blackboard.shared.tcp_port!))
                        let url = URL(string: uri)
                        try _ = String(contentsOf: url!, encoding: String.Encoding.utf8)
                    } catch {
                        print("Failed to connect to url")
                        exit(EX_USAGE)
                    }
                }
                
            case OK_LISTEN:
                return true
                
            default:
                let cmd = try! Parser.guiomaticCommandToOperationAndArgs(guiomaticCommand: rawStage2Command)
                if (cmd.op == Operation.show_main_window) {
                    Blackboard.shared.canMainWindowBeVisible = true
                } else if (cmd.op == Operation.hide_main_window) {
                    Blackboard.shared.canMainWindowBeVisible = false
                }
                let command = CommandFactory.build(forOperation: cmd.op, withArgs: cmd.args)
                Blackboard.shared.unexecuted.push(command)
            }
            return true
        }
        if stage2(command: rawStage2Command) == false { // NOTE: This is a recursive call.
            break
        }
    }
}

do {
    let boot = Boot()
    try runStage1(boot)
    
    /** Start up applications main thread. **/
    app = NSApplication.shared
    appDelegate = AppDelegate()
    app.delegate = appDelegate
    /** The main thread is now running. */
    appDelegate.stageWorker = DispatchQueue(label: "is.mailpile.GUI-o-Mac-tic.stageWorker")
    appDelegate.stageWorker?.async {
        runStage2(boot)
    }
    
}
catch {
    exit(EX_USAGE)
}

_ = NSApplicationMain(CommandLine.argc, CommandLine.unsafeArgv)
