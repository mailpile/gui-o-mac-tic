import AppKit

class SetItem: Command {
    var messageOnError: String = Blackboard.shared.nextErrorMessage
        ?? "Failed to execute 'set_item'."
    
    let id: String
    let label: String?
    let sensitive: Bool
    
    init(_ id: String, _ label: String?, _ sensitive: Bool) {
        self.id = id
        self.label = label
        self.sensitive = sensitive
    }
    
    func execute(sender: NSObject) -> Bool {
        /* Updates the domain model and returns id of the updated item. */
        func updateDomainModel() -> String {
            let allItems = Blackboard.shared.config!.indicator.menu
                + (Blackboard.shared.config?.main_window?.action_items ?? [ActionItem]())
            var item = allItems.first(where: {$0.id == self.id})
            precondition(item != nil, "Unable to 'set_item' for id='\(self.id)' because no item has that id.")
            if self.label != nil {
                item!.label = self.label
            }
            item!.sensitive = self.sensitive
            return item!.id!
        }
        func tryUpdateMenuItemFor(id: String) -> Bool {
            let appDelegate = NSApplication.shared.delegate as! AppDelegate
            guard let menuItem = appDelegate.item2Action[id] else {
                return false
            }
            if self.label != nil {
                menuItem.title = self.label!
            }
            menuItem.isEnabled = self.sensitive
            return true
        }
        func tryUpdateAction(id: String) -> Bool {
            let allItems = Blackboard.shared.config!.indicator.menu
                + (Blackboard.shared.config?.main_window?.action_items ?? [ActionItem]())
            var item = allItems.first(where: {$0.id == self.id})
            guard item != nil else {
                return false
            }
            item?.label = self.label
            item?.sensitive = self.sensitive
            return true
        }
        
        let idOfUpdatedObject = updateDomainModel()
        let didUpdateMenuItem = tryUpdateMenuItemFor(id: idOfUpdatedObject)
        if (!didUpdateMenuItem) {
            let didUpdateAction = tryUpdateAction(id: idOfUpdatedObject)
            assert(didUpdateAction, "Item not found.")
            if !didUpdateAction { return false }
        }
        return true
    }
}
