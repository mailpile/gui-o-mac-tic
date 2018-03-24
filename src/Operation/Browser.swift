import AppKit

final class Browser {
    private init() {
    }
    
    static func openURL(url: URL) {
        NSWorkspace.shared.open(url)
    }
}
