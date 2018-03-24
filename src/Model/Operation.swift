import AppKit

@objc enum Operation: Int {
    typealias RawValue = Int
    case show_url
    case terminal
    case shell
    case quit
    case show_main_window
}
