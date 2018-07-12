import AppKit.NSImage

class Images {
    enum Set {
        case dark
        case light
        
        var description: String {
            switch self {
            case .dark: return "dark"
            case .light: return "light"
            }
        }
    }
    
    private let THEMES_TOKEN = "%(theme)s"
    
    private typealias title2ImageMap = [String: NSImage]
    private var images = [Set : title2ImageMap]()
    
    init() {
        /** XXX:
         Here it would be better to use Set.allCases.forEach {...}, but that can not be done because it requires Swift
         4.2 and that version of swift does not compile on Mailpile's current build machine because that machine runs an
         old version of macOS. */
        func setupDataStructures() {
            self.images[.dark] = title2ImageMap()
            self.images[.light] = title2ImageMap()
        }
        setupDataStructures()
    }
    
    func add(title: String, path: String) {
        func isThemePath() -> Bool {
            return path.range(of: THEMES_TOKEN) != nil
        }
        
        if isThemePath() {
            let lightPath = path.replacingOccurrences(of: THEMES_TOKEN, with: "\(Set.light)")
            if let image = NSImage(contentsOfFile: lightPath) {
                self.images[.light]![title] = image
            }
            let darkPath = path.replacingOccurrences(of: THEMES_TOKEN, with: "\(Set.dark)")
            if let image = NSImage(contentsOfFile: darkPath) {
                self.images[.dark]![title] = image
            }
            return
        } else {
            if let image = NSImage(contentsOfFile: path) {
                self.images[.light]![title] = image
                return
            }
        }
        assertionFailure("\(path) is not an image.")
    }
    
    /**
     Returns an image for the current display mode, fallbacks to the image for the light display mode
     if one cannot be found for the current mode. Returns nil if no image has the provided title in light mode.
     */
    func get(title: String) -> NSImage? {
        if DarkModeChecker.isInDarkMode() {
            if let image = self.images[.dark]![title] {
                return image
            }
        }
        
        if let image = self.images[.light]![title] {
            return image
        }
        
        assertionFailure("No image found with the title \(title).")
        return nil
    }

}
