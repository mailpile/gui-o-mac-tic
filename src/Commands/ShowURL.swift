import AppKit

class ShowURL: Command {
    var messageOnError: String = Blackboard.shared.nextErrorMessage
        ?? "Failed to execute 'show_url'."
    
    let url: URL
    
    init(url: URL) {
        self.url = url
    }
    
    @objc func execute(sender: NSObject) -> Bool {
        let didOpenUrl = NSWorkspace.shared.open(self.url)
        return didOpenUrl
    }
}
