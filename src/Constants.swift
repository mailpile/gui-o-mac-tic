import AppKit

final class Constants {
    private init() {
    }
    
    static let SHOW_MAIN_WINDOW = NSNotification.Name(rawValue: "SHOW_MAIN_WINDOW")
    static let HIDE_MAIN_WINDOW = NSNotification.Name(rawValue: "HIDE_MAIN_WINDOW")
    static let SHOW_SPLASH_SCREEN = NSNotification.Name(rawValue: "SHOW_SPLASH_SCREEN")
    static let HIDE_SPLASH_SCREEN = NSNotification.Name(rawValue: "HIDE_SPLASH_SCREEN")
    static let UPDATE_SPLASH_SCREEN = NSNotification.Name(rawValue: "UPDATE_SPLASH_SCREEN")
    static let SET_STATUS = NSNotification.Name(rawValue: "SET_STATUS")
    static let SET_STATUS_DISPLAY = NSNotification.Name(rawValue: "SET_STATUS_DISPLAY")
    
    static let SPLASH_SEGUE = NSStoryboardSegue.Identifier.init("splashSegue")
    
    static let SUBSTATE_CELL_ID = NSUserInterfaceItemIdentifier.init(rawValue: "SubstatusCell")
    
    static let STATUSBAR = "@statusbar"
    static let SUBSTATUS = "@substatus"
    
    static let DEFAULT_WIDTH = 800
    static let DEFAULT_HEIGHT = 600
}
