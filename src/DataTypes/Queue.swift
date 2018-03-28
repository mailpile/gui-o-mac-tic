import Foundation

struct Queue<Element> {
    var items = [Element]()
    
    var isEmpty: Bool {
        get {
            return items.isEmpty
        }
    }
    
    mutating func push(_ item: Element) {
        items.append(item)
    }
    
    mutating func pop() -> Element {
        return items.removeFirst()
    }
    
    
}
