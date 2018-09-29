import Cocoa

class SplashViewController: NSViewController {
    @IBOutlet weak var notification: NSTextField!
    @IBOutlet weak var imageCell: NSImageCell!
    @IBOutlet weak var progressIndicator: NSProgressIndicator!
    
    @IBOutlet weak var messageLeadingX: NSLayoutConstraint!
    @IBOutlet weak var messageTop: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let fontStyle = Blackboard.shared.config!.fontStyles?.splash {
            self.notification.font = FontStyleToFontMapper.map(fontStyle)
        }
        
        NotificationCenter.default.addObserver(forName: Constants.UPDATE_SPLASH_SCREEN,
                                               object: nil,
                                               queue: nil) { _ in
                                                self.updateSplashScreen();
        }
        
        NotificationCenter.default.addObserver(forName: Constants.SPLASH_SCREEN_NOTIFY_USER, object: nil, queue: nil) { _ in
            guard let message: String = Blackboard.shared.splashMessages.tryPop() else {
                preconditionFailure("Expected a message.")
            }
            self.notification.stringValue = message
            self.viewWillAppear()
        }
        
        NotificationCenter.default.addObserver(forName: Constants.SHOW_SPLASH_SCREEN, object: nil, queue: nil) { _ in
            self.viewWillAppear()
        }
        
        Blackboard.shared.addNotificationDidChange {
            self.notification.stringValue = Blackboard.shared.notification
            self.viewWillAppear()
        }
    }

    func updateSplashScreen() {
        viewWillAppear();
    }
    
    override func viewWillAppear() {
        if let config = Blackboard.shared.splashScreenConfig {
            self.notification.stringValue = config.message
            self.imageCell.image = config.background
            self.view.window?.setContentSize(self.imageCell.image!.size)
            self.progressIndicator.isHidden = !config.showProgressIndicator
            self.progressIndicator.doubleValue = config.progress
        }
        adjustLabel()
                self.view.window?.center()
    }
    
    
    func adjustLabel() {
        self.notification.sizeToFit()
        adjustOffsetX()
        adjustOffsetY()
        self.view.layout()
    }
    
    func adjustOffsetX() {
        let labelWidth = self.notification.frame.width
        let viewWidth  = self.view.frame.width
        self.messageLeadingX.constant =
            viewWidth*CGFloat(Blackboard.shared.splashScreenConfig!.messageX) - labelWidth/2.0
    }
    
    func adjustOffsetY() {
        let labelHeight = CGFloat(self.notification.frame.height)
        let viewHeight = CGFloat(self.imageCell.image!.size.height)
        self.messageTop.constant =
            -1*(viewHeight*CGFloat(Blackboard.shared.splashScreenConfig!.messageY) - labelHeight/2)
    }
}
