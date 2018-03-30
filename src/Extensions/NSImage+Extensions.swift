import AppKit

extension NSImage {
    convenience init?(withTemplatedIconPath: String) {
        let path = withTemplatedIconPath.replacingOccurrences(of: "%(theme)s", with: "OSX")
        self.init(contentsOfFile: path)
    }
}