import AppKit

class NotificationStrategyFactory {
    static func build(preferUserNotificationCenter: Bool) -> NotificationStrategy.Type {
        if !preferUserNotificationCenter {
            let windows: [NSWindow] = NSApplication.shared.windows
            
            let splashWindowIsOpen = windows.contains { window in
                let correctType = window.windowController is SplashWindowController
                return window.isVisible && correctType
            }
            if splashWindowIsOpen {
                return NotifyBySplashScreenMessage.self
            }
            
            let mainWindowIsOpen = windows.contains { window in
                let correctType = window.windowController is MainWindowController
                return window.isVisible && correctType
            }
            if mainWindowIsOpen {
                return NotifyByModal.self
            }
            
            assert(!splashWindowIsOpen && !mainWindowIsOpen)
        }
        
        return NotifyByNotification.self
    }
}
