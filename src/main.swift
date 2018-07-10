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
        /**
         - Returns: true if the for loop may run again.
         */
        func stage2(command: String) -> Bool {
            guard rawStage2Command.isEmpty == false else {
                return true
            }
            
            switch rawStage2Command {
            case OK_GO:
                return false
                
            case let command where command.hasPrefix(OK_LISTEN_TO):
                let listener = Listener()
                listener.command = String(command.dropFirst(OK_LISTEN_TO.count).trimmingCharacters(in: CharacterSet.whitespacesAndNewlines))
                listener.listen()
                
            case let command where command.hasPrefix(OK_LISTEN_TCP):
                /*
                 * NOTE Starts a server for listening to commands over TCP,
                 * which then executes a shell command which triggers commands to
                 * be send over TCP.
                 */
                let closure = { (wasExecutedSuccessfully: inout Bool) -> () in
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
                    wasExecutedSuccessfully = shell.execute(sender: NSObject())
                }
                server.serve(dispatchForExecutionWhenChannelIsOpened: closure)
                
            case let command where command.hasPrefix(OK_LISTEN_HTTP):
                /*
                 * NOTE Starts a server for listening to commands over TCP,
                 * then requests commands to be send over TCP.
                 */
                let closure = { (wasExecutedSuccessfully: inout Bool) -> () in
                    do {
                        var uri = String(command.dropFirst(OK_LISTEN_HTTP.count))
                        uri = uri.trimmingCharacters(in: .whitespaces)
                        uri = uri.replacingOccurrences(of: PORT, with: String(Blackboard.shared.tcp_port!))
                        let url = URL(string: uri)
                        try _ = String(contentsOf: url!, encoding: String.Encoding.utf8)
                        wasExecutedSuccessfully = true
                    } catch {
                        wasExecutedSuccessfully = false
                    }
                }
                server.serve(dispatchForExecutionWhenChannelIsOpened: closure)
                
            case OK_LISTEN:
                return true
                
            default:
                let cmd = try! Parser.guiomaticCommandToOperationAndArgs(guiomaticCommand: rawStage2Command)
                if (cmd.op == Operation.show_main_window) {
                    Blackboard.shared.canMainWindowBeVisible = true
                } else if (cmd.op == Operation.hide_main_window) {
                    Blackboard.shared.canMainWindowBeVisible = false
                }
                /* NOTE: Queues the command - it will be executed once the application has finished launching. */
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
    
    /**
     Checks if the app is being run from a mounted DMG.
     - Returns: `true` if the App's executable is located on a mounted DMG; `false` otherwise.
     */
    func isRunningFromDMG() -> Bool {
        /* 1. First we use hdiutil to get a plist description of mounted volumes. */
        if let plistXML = try? Shell.execute(binary: "/usr/bin/hdiutil", arguments: ["info", "-plist"]).stdout {
            let data = plistXML?.data(using: .utf8)
            let plist = try? PropertyListSerialization.propertyList(from: data!,
                                                                    options: [],
                                                                    format: nil) as! [String:Any]
            /* 2. Then, for every mounted image: */
            if let images = plist?["images"] as? [[String: Any]] {
                for image in images {
                    /* 3. if the image is a DMG file */
                    if let imagePath = image["image-path"] as? String, imagePath.hasSuffix(".dmg"),
                    let entities = image["system-entities"] as? [[String: Any]]
                    {
                        for entity in entities {
                            /* 4. and if that DMG's file's mount point is
                             * a prefix to this application's fully qualified name */
                            if let mountPoint = entity["mount-point"] as? String,
                                Bundle.main.bundleURL.deletingLastPathComponent().path.hasPrefix(mountPoint) {
                                /* 5. then this application is being run from a mounted DMG. */
                                return true
                            }
                        }
                    }
                }
            }
        }
        return false
    }
    if Blackboard.shared.config?.never_run_from_dmg ?? false, isRunningFromDMG()
    {
            let error = "You must install \(ProcessInfo.processInfo.processName) before launching it."
            ErrorNotifier.displayErrorToUser(preferredErrorMessage: error)
    }
    else {
        /* Start up applications main thread. **/
        app = NSApplication.shared
        appDelegate = AppDelegate()
        app.delegate = appDelegate
        /* The main thread is now running. */
        appDelegate.stageWorker = DispatchQueue(label: "is.mailpile.GUI-o-Mac-tic.stageWorker")
        appDelegate.stageWorker?.async {
            runStage2(boot)
        }
    }
    
}
catch {
    exit(EX_USAGE)
}

_ = NSApplicationMain(CommandLine.argc, CommandLine.unsafeArgv)
