import Cocoa

class AppDelegate: NSObject, NSApplicationDelegate, NSUserNotificationCenterDelegate {
    private var config: Config? {
        return Config.shared
    }
    var commands = [Command]()
    var statusBarMenu: NSStatusItem?
    var item2Action = [String: NSMenuItem]()
    var action2Item = [NSMenuItem: String]()
    var item2ConfigAction = [String: Action]()
    
    var _status = "normal"
    var status: String {
        get {
            return self._status
        }
        set {
            self.statusBarMenu?.image = config!.icons[newValue]!.statusBar!
            self._status = newValue
        }
    }
    
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        func buildStatusBarMenu(config: Config) -> NSStatusItem! {
            let statusBarMenu = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)
            func applyStartupIconToMenu() {
                let iconName: String! = config.indicator.initialStatus
                let iconImage: NSImage! = config.icons[iconName]!.statusBar
                statusBarMenu.image = iconImage
            }
            func buildMenuItem(menuItem: Action) -> NSMenuItem {
                if menuItem.separator == true {
                    return NSMenuItem.separator()
                } else {
                    let guiMenuItem = NSMenuItem(title: menuItem.label ?? "", action: nil, keyEquivalent: "")
                    guiMenuItem.isEnabled = menuItem.sensitive == true
                    if guiMenuItem.isEnabled {
                        let command = CommandFactory.build(forOperation: menuItem.op!, withArgs: menuItem.args)
                        self.commands.append(command)
                        guiMenuItem.target = command
                        guiMenuItem.action = #selector(command.execute(sender:))
                        self.action2Item[guiMenuItem] = menuItem.item
                    }
                    return guiMenuItem
                }
            }
            NSUserNotificationCenter.default.delegate = self
            self.statusBarMenu = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)
            applyStartupIconToMenu()
            let menu = NSMenu()
            config.indicator.menu.forEach { configItem in
                let newItem = buildMenuItem(menuItem: configItem)
                menu.addItem(newItem)
                guard let item = configItem.item else { return }
                self.item2Action[item] = newItem
                self.item2ConfigAction[item] = configItem
            }
            statusBarMenu.menu = menu
            return statusBarMenu
        }
        
        self.statusBarMenu = buildStatusBarMenu(config: self.config!)
        NSApplication.shared.windows.forEach { window in window.title = self.config?.app_name ?? "Your App Name" }            
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }
    
    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        return self.config?.main_window?.close_quits ?? false
    }
    
    func userNotificationCenter(_ center: NSUserNotificationCenter, shouldPresent notification: NSUserNotification) -> Bool {
        return true
    }
}
