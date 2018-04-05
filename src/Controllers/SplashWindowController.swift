import Cocoa

class SplashWindowController: NSWindowController {

    override func windowDidLoad() {
        super.windowDidLoad()
        
        NotificationCenter.default.addObserver(forName: Constants.HIDE_SPLASH_SCREEN, object: nil, queue: nil) { _ in
            self.window?.orderOut(self)
        }
    }

}
