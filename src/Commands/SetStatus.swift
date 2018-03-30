import AppKit

class SetStatus: Command {
    let status: String?
    let badge: String?
    
    init(_ status: String?, _ badge: String?) {
        self.status = status
        self.badge = badge
    }
    
    func execute(sender: NSObject) {
        if self.status != nil {
            let delegate = NSApplication.shared.delegate as! AppDelegate
            delegate.status = self.status!
        }
        
        if self.badge != nil {
            NSApp.dockTile.badgeLabel = self.badge
        }
    }
}
