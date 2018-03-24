import AppKit

class Status : NSObject {
    let item: String!
    let label: String!
    let hint: String!
    let icon: NSImage?
    
    init(item: String!, label: String!, hint: String!, icon: NSImage?) {
        self.item = item
        self.label = label
        self.hint = hint
        self.icon = icon
    }
    
    static func ==(lhs: Status, rhs: Status) -> Bool {
        return lhs.item == rhs.item
    }
    
    override var hashValue: Int {
        return item.hashValue
    }
}
