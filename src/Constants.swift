import AppKit

final class Constants {
    private init() {
    }
    
    static let SHOW_MAIN_WINDOW: NSNotification.Name! = NSNotification.Name(rawValue: "Show Main Window")
    static let DATA_SOURCE_UPDATED: NSNotification.Name! = NSNotification.Name(rawValue: "Data Source Ready")
    static let SPLASH_SEGUE: NSStoryboardSegue.Identifier! = NSStoryboardSegue.Identifier.init("splashSegue")
    static let SUBSTATE_CELL_ID = NSUserInterfaceItemIdentifier.init(rawValue: "SubstatusCell")
    
    static let STATUSBAR = "@statusbar"
    static let SUBSTATUS = "@substatus"
    
    static let DEFAULT_WIDTH = 800
    static let DEFAULT_HEIGHT = 600
}
