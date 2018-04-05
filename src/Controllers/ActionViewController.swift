import Cocoa

class ActionTableViewController: NSViewController, NSTableViewDelegate, NSTableViewDataSource {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
    }
    
    func numberOfRows(in tableView: NSTableView) -> Int {
        return 1
    }
    
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        let cell = tableView.makeView(withIdentifier: Constants.BUTTON_CELL_ID, owner: self) as! SubstatusTableCellView
        // assign values to cell.
        return cell
    }
    
    func tableView(_ tableView: NSTableView, shouldSelectRow row: Int) -> Bool {
        return false
    }
}
