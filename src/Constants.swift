import AppKit

final class Constants {
    private init() {
    }
    
    static let NEWLINE_CHAR: Character = "\n"
    
    static let USERINFO_COMMAND = "USERINFO_COMMAND"
    
    // TODO Replace the following notifications with KVO on the blackboard.
    static let SHOW_MAIN_WINDOW = NSNotification.Name(rawValue: "SHOW_MAIN_WINDOW")
    static let HIDE_MAIN_WINDOW = NSNotification.Name(rawValue: "HIDE_MAIN_WINDOW")
    static let SHOW_SPLASH_SCREEN = NSNotification.Name(rawValue: "SHOW_SPLASH_SCREEN")
    static let HIDE_SPLASH_SCREEN = NSNotification.Name(rawValue: "HIDE_SPLASH_SCREEN")
    static let UPDATE_SPLASH_SCREEN = NSNotification.Name(rawValue: "UPDATE_SPLASH_SCREEN")
    static let SET_STATUS = NSNotification.Name(rawValue: "SET_STATUS")
    static let SET_STATUS_DISPLAY = NSNotification.Name(rawValue: "SET_STATUS_DISPLAY")
    static let MAIN_WINDOW_NOTIFY_USER = NSNotification.Name(rawValue: "MAIN_WINDOW_NOTIFY_USER")
    static let SPLASH_SCREEN_NOTIFY_USER = NSNotification.Name(rawValue: "SPLASH_SCREEN_NOTIFY_USER")
    
    static let DOMAIN_UPDATE = NSNotification.Name(rawValue: "DOMAIN_UPDATE")
    
    static let SPLASH_SEGUE = NSStoryboardSegue.Identifier.init("splashSegue")
    
    static let SUBSTATE_CELL_ID = NSUserInterfaceItemIdentifier.init(rawValue: "SubstatusCell")
    static let NOTIFICATION_CELL_ID = NSUserInterfaceItemIdentifier.init(rawValue: "NotificationCell")
    
    static let STATUSBAR = "@statusbar"
    static let SUBSTATUS = "@substatus"
    
    static let DEFAULT_WIDTH = 800
    static let DEFAULT_HEIGHT = 600
    static let DEFAULT_FONT_SIZE = CGFloat(16)
    
    static let NOTIFICATION = "notification"
}
