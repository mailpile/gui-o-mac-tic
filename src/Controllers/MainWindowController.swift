import Cocoa

class MainWindowController: NSWindowController {
    
    var windowSize: CGSize {
        get {
            let width = CGFloat(Config.shared.main_window?.width ?? Constants.DEFAULT_WIDTH)
            let height = CGFloat(Config.shared.main_window?.height ?? Constants.DEFAULT_HEIGHT)
            return NSMakeSize(width, height)
        }
    }
    var isShowable: Bool! {
        return Config.shared.main_window?.show
    }
    
    override func windowDidLoad() {
        super.windowDidLoad()
        self.window!.setContentSize(self.windowSize)
        self.window!.isReleasedWhenClosed = false
        
        NotificationCenter.default.addObserver(forName: Constants.SHOW_MAIN_WINDOW, object: nil, queue: nil) { (_) in
            self.showWindow(nil)
            NSApplication.shared.activate(ignoringOtherApps: true)
        }
        
        NotificationCenter.default.addObserver(forName: Constants.HIDE_MAIN_WINDOW, object: nil, queue: nil) { _ in
            self.window?.orderOut(self)
        }
    }

    override func showWindow(_ sender: Any?) {
        super.showWindow(sender)
        if !isShowable {
            self.window?.orderOut(nil)
        }
    }
}
