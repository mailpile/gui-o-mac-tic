import AppKit

class SetStatusDisplay: Command {
    var messageOnError: String = Blackboard.shared.nextErrorMessage
        ?? "Failed to execute 'set_status_display'."
    
    let id: String
    let title: String?
    let details: String?
    let icon: NSImage?
    let textColour: NSColor?
    
    init(_ id: String, _ title: String?, _ details: String?, _ icon: NSImage?, _ colour: NSColor?) {
        self.id = id
        self.title = title
        self.details = details
        self.icon = icon
        self.textColour = colour
    }
    
    func execute(sender: NSObject) -> Bool {
        guard let main_window = Blackboard.shared.config!.main_window else {
            assertionFailure("Unable to set a status because main_window has not been specified")
            return false
        }
        
        guard let status = main_window.status_displays?.first(where: { $0.id == self.id }) else {
            // NOTE: Unable to set_status_display on "self.id" because no status exists with that id.
            return false
        }
        
        if self.title != nil {
            status.title = self.title!
        }
        if self.details != nil {
            status.details = self.details!
        }
        if self.icon != nil {
            status.icon = self.icon!
        }
        if self.textColour != nil {
            status.textColour = self.textColour!
        }
        
        NotificationCenter.default.post(name: Constants.SET_STATUS_DISPLAY, object: nil)
        
        return true
    }
}
