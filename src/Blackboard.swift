import Foundation

class Blackboard {
    var config: Config?
    
    var nextErrorMessage: String?
    
    var splashMessages = Queue<String>()
    var mainWindowMessages = Queue<String>()
    
    var unexecuted = Queue<Command>()
    
    var tcp_port: UInt16 = 4444 // TODO ASSIGN a random free port.
    
    static let shared = Blackboard()
    private init() {
    }
}
