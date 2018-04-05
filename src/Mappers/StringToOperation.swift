import Foundation

class StringToOperationMapper {
    static func Map(operation: String) -> Operation? {
        switch operation {
        case "show_url":
            return .show_url
        case "terminal":
            return .terminal
        case "shell":
            return .shell
        case "quit":
            return .quit
        case "show_main_window":
            return .show_main_window
        case "get_url":
            return .get_url
        case "post_url":
            return .post_url
        case "show_splash_screen":
            return .show_splash_screen
        case "update_splash_screen":
            return .update_splash_screen
        case "hide_splash_screen":
            return .hide_splash_screen
        case "hide_main_window":
            return .hide_main_window
        case "set_status":
            return .set_status
        case "set_status_display":
            return .set_status_display
        case "set_item":
            return .set_item
        case "set_next_error_message":
            return .set_next_error_message
        case "notify_user":
            return .notify_user
        case "set_http_cookie":
            return .set_http_cookie
        default:
            return nil
        }
    }
}
