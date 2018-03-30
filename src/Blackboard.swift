import Foundation

class Blackboard {
    var config: Config?
    var splashMessages = Queue<String>()
    var mainWindowMessages = Queue<String>()
    var nextErrorMessage: String?
    
    static let shared = Blackboard()
    private init() {
    }
}
