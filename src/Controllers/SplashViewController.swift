import Cocoa

class SplashViewController: NSViewController {
    @IBOutlet weak var reportingLabel: NSTextField!
    @IBOutlet weak var imageCell: NSImageCell!
    @IBOutlet weak var progressIndicator: NSProgressIndicator!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let fontStyle = Config.shared.fontStyles?.splash {
            var font = NSFont.userFont(ofSize: CGFloat(fontStyle.points!))!
            if (fontStyle.family != nil) {
                font = NSFontManager.shared.convert(font, toFamily: fontStyle.family!)
            }
            if fontStyle.bold != nil {
                font = NSFontManager.shared.convert(font, toHaveTrait: NSFontTraitMask.boldFontMask)
            }
            if fontStyle.italic != nil {
                font = NSFontManager.shared.convert(font, toNotHaveTrait: NSFontTraitMask.italicFontMask)
            }
            self.reportingLabel.font = font
        }
        
        NotificationCenter.default.addObserver(forName: Constants.UPDATE_SPLASH_SCREEN,
                                               object: nil,
                                               queue: nil) { notification in
            if let userInfo = notification.userInfo {
                let progress = userInfo["progress"] as! Double
                self.progressIndicator.doubleValue = progress
                
                let message = userInfo["message"] as! String
                self.reportingLabel.stringValue = message
            }
        }
    }
    
    override func viewWillAppear() {
        self.reportingLabel.sizeToFit()
    }
}
