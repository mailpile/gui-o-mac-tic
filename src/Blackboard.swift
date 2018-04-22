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
    
    /** A queue of notifications which shall be displayed as the content of the message label
      in the main window. */
    var mainWindowMessages = Queue<String>()
    
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
    
    /** Returns an shared instance of the Blackboard. */
    static let shared = Blackboard()
    private init() {
    }
}
