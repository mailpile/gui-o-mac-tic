import AppKit

class SetStatus: Command {
    var messageOnError: String = Blackboard.shared.nextErrorMessage
        ?? "Failed to execute 'set_status'."
    
    let status: String?
    let badge: String?
    
    init(_ status: String?, _ badge: String?) {
        self.status = status
        self.badge = badge
    }
    
    func execute(sender: NSObject) {
        if let status = self.status {
            Blackboard.shared.status = status
        }
        
        if let badge = self.badge {
            NSApp.dockTile.badgeLabel = badge
        }
    }
}
