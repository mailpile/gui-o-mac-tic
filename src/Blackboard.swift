import Foundation

class Blackboard {
    var config: Config?
    
    var nextErrorMessage: String?
    
    var splashMessages = Queue<String>()
    var mainWindowMessages = Queue<String>()
    
    var unexecuted = Queue<Command>()
    
    var tcp_port: UInt16?
    
    static let shared = Blackboard()
    private init() {
    }
}
