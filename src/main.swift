import Cocoa
let app = NSApplication.shared
let appDelegate = AppDelegate()
app.delegate = appDelegate

// TODO get the conf by calling "mailpile-gui.py --script"
let file = Bundle.main.url(forResource: "mailpile.onlyjson", withExtension: "json")
let config: Config?
do {
    try config = Parser.parse(jsonConfig: file!)
}
catch {
    print(error) // TODO Error handling.
}

#if DEBUG
    setenv("CFNETWORK_DIAGNOSTICS", "3", 1);
#endif

_ = NSApplicationMain(CommandLine.argc, CommandLine.unsafeArgv)
