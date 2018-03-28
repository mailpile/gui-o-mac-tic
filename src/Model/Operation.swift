import AppKit

@objc enum Operation: Int {
    typealias RawValue = Int

    case get_url
    case post_url
    case shell
    case show_splash_screen
    case update_splash_screen
    case hide_splash_screen
    case show_main_window
    case hide_main_window
    case set_status
    case set_status_display
    case set_item
    case set_next_error_message
    case notify_user
    case show_url
    case terminal
    case set_http_cookie
    case quit 
}
