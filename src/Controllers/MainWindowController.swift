 import Cocoa

class MainWindowController: NSWindowController, NSWindowDelegate {
    
    var windowSize: CGSize {
        get {
            let width = CGFloat(Blackboard.shared.config!.main_window?.width ?? Constants.DEFAULT_WIDTH)
            let height = CGFloat(Blackboard.shared.config!.main_window?.height ?? Constants.DEFAULT_HEIGHT)
            return NSMakeSize(width, height)
        }
    }
    
    override func windowDidLoad() {
        super.windowDidLoad()
        self.window!.setContentSize(self.windowSize)
        self.window!.isReleasedWhenClosed = false
        
        NotificationCenter.default.addObserver(forName: Constants.SHOW_MAIN_WINDOW, object: nil, queue: nil) { _ in
            self.showWindow(self)
        }
        
        NotificationCenter.default.addObserver(forName: Constants.HIDE_MAIN_WINDOW, object: nil, queue: nil) { _ in
            self.window?.orderOut(self)
        }
        
        (self.contentViewController as! MainWindowViewController).sizeToFit(statusDisplayCount: 3)
    }

    override func showWindow(_ sender: Any?) {
        if Blackboard.shared.canMainWindowBeVisible {
            NSApplication.shared.activate(ignoringOtherApps: true)
            super.showWindow(sender)
        } else {
            self.window?.orderOut(self)
        }
    }
    
    func windowShouldClose(_ sender: NSWindow) -> Bool {
        HideMainWindow().execute(sender: self)
        return false
    }
}
