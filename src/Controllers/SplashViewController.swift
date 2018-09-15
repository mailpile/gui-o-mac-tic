import Cocoa

class SplashViewController: NSViewController {
    @IBOutlet weak var notification: NSTextField!
    @IBOutlet weak var imageCell: NSImageCell!
    @IBOutlet weak var progressIndicator: NSProgressIndicator!
    
    @IBOutlet weak var messageLeadingX: NSLayoutConstraint!
    @IBOutlet weak var messageTop: NSLayoutConstraint!
    
    public var messageX: Float = 0.5
    public var messageY: Float = 0.5
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let fontStyle = Blackboard.shared.config!.fontStyles?.splash {
            self.notification.font = FontStyleToFontMapper.map(fontStyle)
        }
        
        NotificationCenter.default.addObserver(forName: Constants.UPDATE_SPLASH_SCREEN,
                                               object: nil,
                                               queue: nil) { notification in
            if let userInfo = notification.userInfo {
                let progress = userInfo["progress"] as! Double
                self.progressIndicator.doubleValue = progress
                
                let message = userInfo["message"] as! String
                self.notification.stringValue = message
            }
        }
        
        NotificationCenter.default.addObserver(forName: Constants.SPLASH_SCREEN_NOTIFY_USER, object: nil, queue: nil) { _ in
            guard let message: String = Blackboard.shared.splashMessages.tryPop() else {
                preconditionFailure("Expected a message.")
            }
            self.notification.stringValue = message
            self.notification.sizeToFit()
        }
        
        Blackboard.shared.addNotificationDidChange {
            self.notification.stringValue = Blackboard.shared.notification
            self.notification.sizeToFit()
        }
    }
    
    override func viewWillAppear() {
        self.notification.sizeToFit()
        
        func adjustOffsetX() {
            let labelWidth = self.notification.frame.width
            let viewWidth = self.view.frame.width
            let width = viewWidth - labelWidth
            let x = messageX * Float(width)
            self.messageLeadingX.constant = CGFloat(x)
        }
        adjustOffsetX()
        
        func adjustOffsetY() {
            let labelHeight = self.notification.frame.height
            let viewHeight = self.view.frame.height
            let height = viewHeight - labelHeight
            let y = -(messageY * Float(height))
            self.messageTop.constant = CGFloat(y)
        }
        adjustOffsetY()
    }
}
