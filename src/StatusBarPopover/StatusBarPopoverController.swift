import Cocoa

class StatusBarPopoverController: NSViewController,
                                  NSPopoverDelegate {
    @IBOutlet weak var textUnderArrow: NSTextFieldCell!
    private var text: String?
    private let popover = NSPopover()
    
    convenience init(text: String) {
        self.init()
        self.text = text
        self.popover.contentViewController = self
        self.popover.behavior = .applicationDefined
        self.popover.delegate = self
    }
    
    override func viewDidLoad() {
        assert(self.text != nil, "Expected this class to be constructed by init(text:).")
        assert(self.popover.contentViewController === self, "Expected this class to be constructed by init(text:).")
        assert(self.popover.behavior == .applicationDefined, "Expected this class to be constructed by init(text:).")
        assert(self.popover.delegate === self, "Expected this class to be constructed by init(text:).")
        
        super.viewDidLoad()
        self.textUnderArrow.stringValue = self.text ?? ""
    }
    
    /**
      Displays a popover which is automatically closed after a given amount of time.
     */
    func showPopover(relativeTo: NSRect, of: NSView, preferredEdge: NSRectEdge, closeAfter: DispatchTimeInterval ) {
        self.popover.show(relativeTo: relativeTo, of: of, preferredEdge: preferredEdge)
        DispatchQueue.main.asyncAfter(wallDeadline: DispatchWallTime.now() + closeAfter,
                                      execute: { self.closePopover() })
        
    }
    
    /**
     Forces the popover to close without consulting it's delegate.
    */
    func closePopover() {
        self.popover.close()
    }
}
