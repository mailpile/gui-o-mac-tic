import AppKit

class SetStatus: Command {
    let status: String
    
    init(_ status: String) {
        self.status = status
    }
    
    func execute(sender: NSObject) {
        let delegate = NSApplication.shared.delegate as! AppDelegate
        delegate.status = self.status
    }
}
