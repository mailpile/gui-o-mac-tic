import Foundation

class Blackboard {
    var config: Config?
    
    var nextErrorMessage: String?
    
    var splashMessages = Queue<String>()
    var mainWindowMessages = Queue<String>()
    
    var unexecuted = Queue<Command>()
    
    static let shared = Blackboard()
    private init() {
    }
}
