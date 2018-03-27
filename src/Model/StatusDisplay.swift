import AppKit

class StatusDisplay : NSObject {
    var id: String
    var title: String
    var details: String
    var icon: NSImage?
    var textColour: NSColor?
    
    init(item: String, label: String, hint: String, icon: NSImage?) {
        self.id = item
        self.title = label
        self.details = hint
        self.icon = icon
    }
    
    static func ==(lhs: StatusDisplay, rhs: StatusDisplay) -> Bool {
        return lhs.id == rhs.id
    }
    
    override var hashValue: Int {
        return id.hashValue
    }
}
