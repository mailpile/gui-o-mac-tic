import AppKit

class ShowURL: Command {
    var messageOnError: String = Blackboard.shared.nextErrorMessage
        ?? "Failed to execute 'show_url'."
    
    let url: URL
    
    init(url: URL) {
        self.url = url
    }
    
    @objc func execute(sender: NSObject) {
        let didOpenUrl = NSWorkspace.shared.open(self.url)
        if !didOpenUrl {
            /* TODO Error handling, url could not be opened. */
            assertionFailure("Not implemented.")
        }
    }
}
