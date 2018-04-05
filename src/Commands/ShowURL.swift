import AppKit

class ShowURL: Command {    
    let url: URL
    
    init(url: URL) {
        self.url = url
    }
    
    @objc func execute(sender: NSObject) {
        /* TODO Ensure the browser opens the URL in the same as is used to interact with a web application. */
        let didOpenUrl = NSWorkspace.shared.open(self.url)
        if !didOpenUrl {
            /* TODO Error handling, url could not be opened. */
            assertionFailure("Not implemented.")
        }
        
    }
}
