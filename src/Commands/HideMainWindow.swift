import Foundation

class HideMainWindow: Command {
    func execute(sender: NSObject) {
        NotificationCenter.default.post(name: Constants.HIDE_MAIN_WINDOW, object: nil)
    }
}
