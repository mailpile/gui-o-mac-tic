import Cocoa

class AppDelegate: NSObject,
                   NSApplicationDelegate,
                   NSUserNotificationCenterDelegate,
                   NSMenuDelegate {
    public var stageWorker: DispatchQueue? = nil
    private var commands = [Command]()
    var statusBarMenu: NSStatusItem?
    var item2Action = [String: NSMenuItem]()
    private var action2Item = [NSMenuItem: String]()
    private var item2ConfigAction = [String: ActionItem]()
    private var popoverController: StatusBarPopoverController?
    
    private func resizeToFitIfNeeded(image: inout NSImage, statusbar: NSStatusItem) {
        let maxLength = statusbar.statusBar?.thickness ?? CGFloat(22)
        guard image.size.height > maxLength || image.size.width > maxLength else { return }
        let lengthWhichLooksGoodOnToolbar = maxLength * CGFloat(0.8)
        let iconSize = NSMakeSize(lengthWhichLooksGoodOnToolbar, lengthWhichLooksGoodOnToolbar)
        image = NSImage.init(withImage: image, resizedTo: iconSize)
        NSLog("The status bar icon had to be resized because it was larger than"
            + " \(UInt(maxLength))×\(UInt(maxLength)).")
    }
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        let statusBarMenu = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)
        func buildStatusBarMenu(config: Config) -> NSStatusItem! {
            func applyStartupIconToMenu() {
                let iconName: String! = config.indicator.initialStatus
                var iconImage: NSImage = config.icons[iconName]!
                resizeToFitIfNeeded(image: &iconImage, statusbar: statusBarMenu)
                statusBarMenu.image = iconImage
            }
            func buildMenuItem(menuItem: ActionItem) -> NSMenuItem {
                if menuItem.separator == true {
                    return NSMenuItem.separator()
                } else {
                    let guiMenuItem = NSMenuItem(title: menuItem.label ?? "", action: nil, keyEquivalent: "")
                    guiMenuItem.isEnabled = menuItem.sensitive == true
                    if let operation = menuItem.op {
                        let command = CommandFactory.build(forOperation: operation, withArgs: menuItem.args)
                        self.commands.append(command)
                        guiMenuItem.target = command
                        guiMenuItem.action = #selector(command.execute(sender:))
                        self.action2Item[guiMenuItem] = menuItem.id
                    }
                    return guiMenuItem
                }
            }
            NSUserNotificationCenter.default.delegate = self
            applyStartupIconToMenu()
            let menu = NSMenu()
            menu.delegate = self
            menu.autoenablesItems = false
            config.indicator.menu.forEach { configItem in
                let newItem = buildMenuItem(menuItem: configItem)
                menu.addItem(newItem)
                guard let item = configItem.id else { return }
                self.item2Action[item] = newItem
                self.item2ConfigAction[item] = configItem
            }
            statusBarMenu.menu = menu
            return statusBarMenu
        }

        self.statusBarMenu = buildStatusBarMenu(config: Blackboard.shared.config!)
        NSApplication.shared.windows.forEach { window in window.title = Blackboard.shared.config!.app_name }
        
        while let command = Blackboard.shared.unexecuted.tryPop() {
            _ = command.execute(sender: self)
        }
        
        /* If a status bar popover message was specified in the config, display it. */
        if let messageToShowInStatusBarPopup = Blackboard.shared.config?.status_bar_popover_message {
            func getStatusBarView() -> NSView? {
                if let appDelegate = (NSApp.delegate as? AppDelegate)
                    , let statusBarItem = appDelegate.statusBarMenu
                    , let statusBarWindow = statusBarItem.value(forKey: "window") as? NSWindow
                    , let targetView = statusBarWindow.contentView {
                    return targetView
                }
                return nil
            }
            if let statusBarView = getStatusBarView() {
                self.popoverController = StatusBarPopoverController(text: messageToShowInStatusBarPopup)
                self.popoverController!.showPopover(relativeTo: statusBarView.frame,
                                                    of: statusBarView,
                                                    preferredEdge: .maxY,
                                                    closeAfter: DispatchTimeInterval.seconds(5))
            }
        }
        
        Blackboard.shared.addStatusDidChange {
            var icon = Blackboard.shared.config!.icons[Blackboard.shared.status]
            self.resizeToFitIfNeeded(image: &icon!, statusbar: self.statusBarMenu!)
            self.statusBarMenu?.image = icon
        }
        
        Blackboard.shared.addNotificationDidChange {
            self.item2Action["notification"]?.title = Blackboard.shared.notification
        }
        
        if !Blackboard.shared.notification.isEmpty {
            self.item2Action["notification"]?.title = Blackboard.shared.notification
        }
    }
    
    func menuWillOpen(_ menu: NSMenu) {
        self.popoverController?.closePopover()
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        if Blackboard.shared.openedTerminalWindows.count > 0 {
            func closeTerminalWindowsWith(windowIds: [Int32]) {
                // Convert windowIds to a string list.
                var windowIdsString = ""
                for id in windowIds {
                    windowIdsString.append("\(id),")
                }
                windowIdsString.removeLast()
                
                // Load applescript and insert the ids if the windows to be closed.
                let template = Bundle.main.url(forResource: "CloseTerminalWindows", withExtension: "applescript")!
                var script = try! String(contentsOf: template)
                script = script.replacingOccurrences(of: "WINDOW_IDS_TOKEN", with:windowIdsString)
                
                let appleScript = NSAppleScript.init(source: script)
                var errorInfo: NSDictionary?
                appleScript?.executeAndReturnError(&errorInfo)
                assert (errorInfo == nil)
            }
            closeTerminalWindowsWith(windowIds: Blackboard.shared.openedTerminalWindows)
        }
        stageWorker = nil
    }
    
    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        return Blackboard.shared.config!.main_window?.close_quits ?? false
    }
    
    func userNotificationCenter(_ center: NSUserNotificationCenter,
                                shouldPresent notification: NSUserNotification) -> Bool {
        return true
    }
    
    func userNotificationCenter(_ center: NSUserNotificationCenter, didActivate notification: NSUserNotification) {
        guard notification.identifier != nil else { return }
        if let actions: [ActionItem] = Blackboard.shared.notificationIdentifier2Actions.removeValue(forKey: notification.identifier!) {
            func getAction(withLabel label: String?) -> ActionItem? {
                return actions.first(where: { $0.label == label })
            }
            var action: ActionItem? = nil
            switch notification.activationType {
            case .actionButtonClicked:
                action = getAction(withLabel: notification.actionButtonTitle)
            case .additionalActionClicked:
                action = getAction(withLabel: notification.additionalActivationAction?.title)
            case .contentsClicked,
                 .none:
                break
            case .replied:
                preconditionFailure("Unreachable.")
            }
            guard action != nil else { return }
            let command = CommandFactory.build(forOperation: action!.op!, withArgs: action!.args)
            _ = command.execute(sender: self)
        }
    }
    
    func applicationShouldHandleReopen(_ sender: NSApplication, hasVisibleWindows flag: Bool) -> Bool {
        _ = ShowMainWindow().execute(sender: self)
        return false
    }
    
    func applicationWillResignActive(_ notification: Notification) {
        self.popoverController?.closePopover()
    }
}
