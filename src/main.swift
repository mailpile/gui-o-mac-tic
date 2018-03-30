import Cocoa
let app = NSApplication.shared
let appDelegate = AppDelegate()
app.delegate = appDelegate

let configurator = Configurator()


let config: Config?
do {
    try config = Parser.parse(json: configurator.part1)
}
catch {
    print(error) // TODO Error handling.
}

#if DEBUG
    setenv("CFNETWORK_DIAGNOSTICS", "3", 1);
#endif

_ = NSApplicationMain(CommandLine.argc, CommandLine.unsafeArgv)
