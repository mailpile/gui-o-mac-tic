import Cocoa

class GUI: NSObject {
    let ICON_THEME = "light"
    let config: Config
    var ready: Bool
    var next_error_message: String?
    
    init(config: Config) {
        self.config = config
        self.ready = false
        self.next_error_message = nil
    }
    
    func run() {
        print("run()")
        /* TODO */
    }
    
    func report_error(error: String) {
        /* TODO */
    }
}
