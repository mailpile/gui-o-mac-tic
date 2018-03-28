import AppKit

class NotificationStrategyFactory {
    static func build(preferPopup: Bool) -> NotificationStrategy.Type {
        let windows: [NSWindow] = NSApplication.shared.windows
        
        func isVisibleAndIsType<T>(_ window: NSWindow, _ type: T) -> Bool {
            return window.windowController is T
                && window.isVisible
        }
        
        let splashWindowIsOpen = windows.contains { window in isVisibleAndIsType(window, SplashWindowController.self) }
        if splashWindowIsOpen {
            return NotifyBySplashScreenMessage.self
        }
        
        let mainWindowIsOpen = windows.contains { window in isVisibleAndIsType(window, MainWindowController.self) }
        if mainWindowIsOpen {
            return NotifyByModal.self
        }
        
        assert(!splashWindowIsOpen && !mainWindowIsOpen)
        return NotifyByNotification.self
    }
}
