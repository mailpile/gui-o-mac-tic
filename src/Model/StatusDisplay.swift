import AppKit

class StatusDisplay : NSObject {
    var id: String
    var title: String
    var details: String?
    var icon: NSImage?
    var textColour: NSColor?
    
    init(item: String, title: String, details: String?, icon: NSImage?) {
        self.id = item
        self.title = title
        self.details = details
        self.icon = icon
    }
    
    static func ==(lhs: StatusDisplay, rhs: StatusDisplay) -> Bool {
        return lhs.id == rhs.id
    }
    
    override var hashValue: Int {
        return id.hashValue
    }
}
