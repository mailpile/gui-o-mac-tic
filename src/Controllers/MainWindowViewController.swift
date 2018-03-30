import Cocoa

class MainWindowViewController: NSViewController, NSTableViewDelegate, NSTableViewDataSource, SplashScreenDataSource {
    
    var splashScreenConfig: SplashScreenConfig?
    var button2Action = [NSButton: ActionItem]()
    var commands = [Command]()
    
    @IBOutlet weak var background: NSImageView!
    @IBOutlet weak var substatusView: NSTableView!
    @IBOutlet weak var actionStack: NSStackView!
    @IBOutlet weak var message: NSTextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        func configureActionStack() {
            func mapPosition2Gravity(position: Position) -> NSStackView.Gravity {
                switch position {
                case .first:
                    return .leading
                case .last:
                    return .trailing
                }
            }
            Blackboard.shared.config!.main_window?.actions.forEach { action in
                let buttonInit: ((String, Any?, Selector?) -> NSButton)
                    switch action.type {
                    case .checkbox?:
                        buttonInit = NSButton.init(checkboxWithTitle:target:action:)
                    case .button?:
                        buttonInit = NSButton.init(title:target:action:)
                    case nil:
                        buttonInit = NSButton.init(title:target:action:)
                    }
                let command = CommandFactory.build(forOperation: action.op!, withArgs: action.args)
                self.commands.append(command)
                let control = buttonInit(action.label!, command, #selector(command.execute(sender:)))
                let gravity = mapPosition2Gravity(position: action.position!)
                self.actionStack.addView(control, in: gravity)
                self.button2Action[control] = action
            }
        }
        NotificationCenter.default.addObserver(forName: Constants.SHOW_SPLASH_SCREEN, object: nil, queue: nil) { notification in
            guard
                let userInfo = notification.userInfo,
                let background = userInfo["background"] as? NSImage,
                let message = userInfo["message"] as? String,
                let showProgressBar = userInfo["showProgressBar"] as? Bool?
                else {
                    preconditionFailure("Observed a \(Constants.SHOW_SPLASH_SCREEN) notification without a valid userInfo.")
            }
            self.splashScreenConfig = SplashScreenConfig(message, background, showProgressBar ?? false)
            self.showSplashScreen()
        }
        
        NotificationCenter.default.addObserver(forName: Constants.SET_STATUS_DISPLAY, object: nil, queue: nil) { _ in
            self.substatusView.reloadData()
        }
        
        NotificationCenter.default.addObserver(forName: Constants.MAIN_WINDOW_NOTIFY_USER, object: nil, queue: nil) { _ in
            guard let message: String = Blackboard.shared.mainWindowMessages.tryPop() else {
                preconditionFailure("Expected a message.")
            }
            self.message.stringValue = message
            self.message.sizeToFit()
        }
        
        configureActionStack()
        self.background.image = Blackboard.shared.config!.main_window?.image
    }
        
    func numberOfRows(in tableView: NSTableView) -> Int {
        return Blackboard.shared.config!.main_window?.status?.count ?? 0
    }
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        let cell = tableView.makeView(withIdentifier: Constants.SUBSTATE_CELL_ID, owner: self) as! SubstatusTableCellView
        let status = Blackboard.shared.config!.main_window!.status![row]
        cell.titleView.stringValue = status.title
        cell.descriptionView.stringValue = status.details ?? ""
        cell.iconView.image = status.icon
        
        if let colour = status.textColour {
            cell.titleView.textColor = colour
            cell.descriptionView.textColor = colour
        }
        
        return cell
    }
    
    func tableView(_ tableView: NSTableView, shouldSelectRow row: Int) -> Bool {
        return false
    }
    
    override func prepare(for segue: NSStoryboardSegue, sender: Any?) {
        if let targetWindowController = segue.destinationController as? NSWindowController,
            let targetViewController = targetWindowController.contentViewController as? SplashViewController {
            targetViewController.reportingLabel.stringValue = splashScreenConfig!.message
            targetViewController.imageCell.image = splashScreenConfig!.background
            targetViewController.progressIndicator.isHidden = splashScreenConfig!.showProgressIndicator == false
        } else {
            assertionFailure("Expected a single segue from this controller, leading to a NSWindowController.")
        }
    }
    
    func showSplashScreen() {
        performSegue(withIdentifier: Constants.SPLASH_SEGUE, sender: self)
    }
}
