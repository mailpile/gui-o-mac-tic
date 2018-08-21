import Foundation

/**
 Detects if macOS is in dark mode.
 */
class DarkModeChecker {
    static func isInDarkMode() -> Bool {
        return UserDefaults.standard.string(forKey: "AppleInterfaceStyle") == "Dark"
    }
}
