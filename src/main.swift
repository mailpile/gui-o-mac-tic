import Cocoa
let app = NSApplication.shared
let appDelegate = AppDelegate()
app.delegate = appDelegate
var server = Server()
func rawCommandToOperationAndArgs(rawCommand: String) -> (op: Operation, args: Args) {
    let keyValuePair = rawCommand.split(separator: " ", maxSplits: 1)
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

do {
    let boot = Boot()
    boot.boot()
    try Blackboard.shared.config = Parser.parse(json: boot.part1!)
    for rawStage2Command: String in boot.part2 {
        guard rawStage2Command.isEmpty == false else {
            continue
        }
        
        switch rawStage2Command {
        case "OK GO":
            break
        
        case let command where command.hasPrefix("OK LISTEN TO:"):
            preconditionFailure("Not yet implemented.")
        
        case let command where command.hasPrefix("OK LISTEN TCP:"):
            var shellCommand = String(command.dropFirst("OK LISTEN TCP:".count))
            shellCommand = shellCommand.trimmingCharacters(in: .whitespaces)
            shellCommand = shellCommand.replacingOccurrences(of: "%PORT%", with: String(Blackboard.shared.tcp_port))
            DispatchQueue.global(qos: .background).async {
                server.go()
            }
            let shell = Terminal(shellCommand)
            shell.execute(sender: NSString(string: "not used"))
            
        case let command where command.hasPrefix("OK LISTEN HTTP:"):
            preconditionFailure("Not yet implemented.")
            
        case "OK LISTEN":
            continue
        
        default:
            let cmd = rawCommandToOperationAndArgs(rawCommand: rawStage2Command)
            let command = CommandFactory.build(forOperation: cmd.op, withArgs: cmd.args)
            Blackboard.shared.unexecuted.push(command)
        }
    }
}
catch {
    print(error) // TODO Error handling.
    exit(EX_USAGE)
}

#if DEBUG
    setenv("CFNETWORK_DIAGNOSTICS", "3", 1);
#endif

_ = NSApplicationMain(CommandLine.argc, CommandLine.unsafeArgv)
