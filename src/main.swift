import Cocoa
let app = NSApplication.shared
let appDelegate = AppDelegate()
app.delegate = appDelegate

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
    let configurator = Configurator()
    try Blackboard.shared.config = Parser.parse(json: configurator.part1)
    for rawStage2Command: String in configurator.part2 {
        guard rawStage2Command.isEmpty == false else {
            continue
        }
        
        switch rawStage2Command {
        case "OK GO":
            break
        
        case "OK LISTEN":
            continue
        
        case let command where command.hasPrefix("OK LISTEN TO:"):
            preconditionFailure("Not yet implemented.")
        
        case let command where command.hasPrefix("OK LISTEN TCP:"):
            preconditionFailure("Not yet implemented.")
            
        case let command where command.hasPrefix("OK LISTEN HTTP:"):
            preconditionFailure("Not yet implemented.")
        
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
