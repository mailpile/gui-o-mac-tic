import Cocoa

class SplashViewController: NSViewController {

    @IBOutlet weak var reportingLabel: NSTextField!
    
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
        self.reportingLabel.sizeToFit()
    }
    
}
