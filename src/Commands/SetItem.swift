import AppKit

class SetItem: Command {
    let id: String
    let label: String?
    let sensitive: Bool
    
    init(_ id: String, _ label: String?, _ sensitive: Bool) {
        self.id = id
        self.label = label
        self.sensitive = sensitive
    }
    
    func execute(sender: NSObject) {
        /* Updates the domain model and returns id of the updated item. */
        func updateDomainModel() -> String {
            var item = Config.shared.indicator.menu.first(where: {$0.id == self.id})
            precondition(item != nil, "Unable to 'set_item' for id='\(self.id)' because no item has that id.")
            if self.label != nil {
                item!.label = self.label
            }
            item!.sensitive = self.sensitive
            return item!.id!
        }
        func updateMenuItemFor(id: String) {
            let appDelegate = NSApplication.shared.delegate as! AppDelegate
            let menuItem = appDelegate.item2Action[id]!
            if self.label != nil {
                menuItem.title = self.label!
            }
            menuItem.isEnabled = self.sensitive
            
        }
        
        let idOfUpdatedObject = updateDomainModel()
        updateMenuItemFor(id: idOfUpdatedObject)
    }
}
