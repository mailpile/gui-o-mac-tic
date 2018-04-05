import Foundation
class ShowMainWindow: Command {
    func execute(sender: NSObject) {
        NotificationCenter.default.post(name: Constants.SHOW_MAIN_WINDOW, object: nil)
    }
}
