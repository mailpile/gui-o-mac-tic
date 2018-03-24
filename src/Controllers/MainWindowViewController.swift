import Cocoa

class MainWindowViewController: NSViewController, NSTableViewDelegate, NSTableViewDataSource {
    var button2Action = [NSButton: Action]()
    
    @IBOutlet weak var background: NSImageView!
    @IBOutlet weak var substatusView: NSTableView!
    @IBOutlet weak var actionStack: NSStackView!
    
    private var config: Config! {
        get {
            return Config.shared!
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        showSplashScreen()
        func configureActionStack() {
            func mapPosition2Gravity(position: Position) -> NSStackView.Gravity {
                switch position {
                case .first:
                    return .leading
                case .last:
                    return .trailing
                }
            }
            self.config.main_window?.actions.forEach { action in
                let buttonInit: ((String, Any?, Selector?) -> NSButton)
                switch action.type! {
                case .checkbox:
                    buttonInit = NSButton.init(checkboxWithTitle:target:action:)
                case .button:
                    buttonInit = NSButton.init(title:target:action:)
                }
                let control = buttonInit(action.label!, nil, #selector(self.actionExecutionHandler(sender:)))
                let gravity = mapPosition2Gravity(position: action.position!)
                self.actionStack.addView(control, in: gravity)
                self.button2Action[control] = action
            }
        }
        
        configureActionStack()
        self.background.image = self.config.main_window?.image
    }
    
    @objc func actionExecutionHandler(sender: NSButton!) {
        let action: Action! = button2Action[sender]
        OperationExecutor.execute(operation:action.op!, args:action.args)
    }
    
    func numberOfRows(in tableView: NSTableView) -> Int {
        return self.config.main_window?.substatus?.count ?? 0
    }
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        let cell = tableView.makeView(withIdentifier: Constants.SUBSTATE_CELL_ID, owner: self) as! SubstatusTableCellView
        let substatus = self.config.main_window!.substatus![row]
        cell.titleView.stringValue = substatus.label
        cell.descriptionView.stringValue = substatus.hint
        cell.iconView.image = substatus.icon
        return cell
    }
    
    func tableView(_ tableView: NSTableView, shouldSelectRow row: Int) -> Bool {
        return false
    }
    
    func showSplashScreen() {
        performSegue(withIdentifier: Constants.SPLASH_SEGUE, sender: self)
    }
}
