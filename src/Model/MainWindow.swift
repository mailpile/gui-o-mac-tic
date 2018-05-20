import AppKit

struct MainWindow {
    let show: Bool
    let message: String?
    let close_quits: Bool
    let width: Int
    let height: Int
    let image: NSImage?
    var action_items: [ActionItem]
    let status_displays: [StatusDisplay]?
    let initial_notification: String
}
