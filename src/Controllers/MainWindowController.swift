 import Cocoa

class MainWindowController: NSWindowController {
    
    var windowSize: CGSize {
        get {
            let width = CGFloat(Blackboard.shared.config!.main_window?.width ?? Constants.DEFAULT_WIDTH)
            let height = CGFloat(Blackboard.shared.config!.main_window?.height ?? Constants.DEFAULT_HEIGHT)
            return NSMakeSize(width, height)
        }
    }
    
    var shouldShowWindow = Blackboard.shared.config!.main_window!.show
    
    override func windowDidLoad() {
        super.windowDidLoad()
        self.window!.setContentSize(self.windowSize)
        self.window!.isReleasedWhenClosed = false
        
        NotificationCenter.default.addObserver(forName: Constants.SHOW_MAIN_WINDOW, object: nil, queue: nil) { _ in
            self.shouldShowWindow = true
            self.showWindow(self)
            NSApplication.shared.activate(ignoringOtherApps: true)
        }
        
        NotificationCenter.default.addObserver(forName: Constants.HIDE_MAIN_WINDOW, object: nil, queue: nil) { _ in
            self.shouldShowWindow=false
            self.window?.orderOut(self)
        }
        
    }

    override func showWindow(_ sender: Any?) {
        if self.shouldShowWindow {
            super.showWindow(sender)
        } else {
            self.window?.orderOut(self)
        }
    }
}
