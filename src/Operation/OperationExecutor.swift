import AppKit

@objc class OperationExecutor : NSObject{
    static private func quitApplication() {
        NSApplication.shared.terminate(self)
    }
    
    @objc static func execute(operation: Operation, args: Args) {
        switch operation {
        case .quit:
            quitApplication()
            
        case .show_main_window:
            NotificationCenter.default.post(name: Constants.SHOW_MAIN_WINDOW, object: nil)
            
        case .terminal:
            Terminal.execute(command: args.dictionary!["command"]!, terminalWindowTitle: args.dictionary!["title"]!)
            
        case .show_url:
            args.list?.forEach { string in
                if let url = URL(string: string) {
                    Browser.openURL(url: url)
                }
            }
            
        case .shell:
            args.list?.forEach { command in
                let commandComponents: [String] = command.components(separatedBy: .whitespaces)
                Shell.execute(commandComponents)
            }
        }
    }
}
