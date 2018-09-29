import Foundation

/**
  A Blackboard holds variables which are shared among threads.
  - SeeAlso:
    Lalanda, Philippe. "Two complementary patterns to build multi-expert systems."
    Pattern Languages of Programs.1997.
*/
class Blackboard {
    /** This application's configuration; an instance of the first stage in the GUI-o-matic protocol. */
    var config: Config?
    
    /** The next error message to be displayed.
      This variable shall only be set by gui-o-matic protocol statements. */
    var nextErrorMessage: String?
    
    /** A queue of messages and notifications which shall be displayed as the content of the message label
      in the splash screen. */
    var splashMessages = Queue<String>()
    
    /** Closures to be executed when `notification`'s rval is changed. */
    private var notificationDidChange = [(()->())]()
    
    /** Add a closure which will be executed when `notification`'s rval is changed. */
    public func addNotificationDidChange(closure: @escaping (()->())) {
        notificationDidChange.append(closure)
    }
    /** A notifications which shall be displayed to the user. */
    var notification: String = "" {
        didSet {
            for closure in notificationDidChange {
                closure()
            }
        }
    }
    
    /** The config of the splash screen. */
    var splashScreenConfig: SplashScreenConfig?
    
    /** Closures to be executed when `status`'s rval is changed. */
    private var statusDidChange = [(()->())]()
    
    /** Add a closure which will be executed when `status`'s rval is changed. */
    public func addStatusDidChange(closure: @escaping (()->())) {
        statusDidChange.append(closure)
    }
    
    /** The application's status. */
    var status: String = "" {
        didSet {
            for closure in statusDidChange {
                closure()
            }
        }
    }
    
    /** A queue of commands which are yet to be executed.
      A command shall be removed, by the executer, from this queue upon execution. */
    var unexecuted = Queue<Command>()
    
    /** The TCP port on which this application is listening or 0 when it is not listening. */
    var tcp_port: UInt16?

    /**
      Maps a notification to one or more actions.
      - Important:
      The notification's identifier (NSUserNotification.identifier)
      is used as a key, as opposite to the actual notification which can not be used as a key.
      This is because Apple's notification mechanism reconstructs the notification object at various
      points during execution.
     */
    var notificationIdentifier2Actions = [String:[ActionItem]]()
    
    /** Indicates whether the main window may be visible to the user. */
    var canMainWindowBeVisible = false
    
    /** ID's of terminal windows which were opened by executing the Terminal command. */
    var openedTerminalWindows = [Int32]()
    
    /** Returns an shared instance of the Blackboard. */
    static let shared = Blackboard()
    private init() {
    }
}
