import AppKit

extension NSImage {
    convenience init?(withTemplatedIconPath: String) {
        let path = withTemplatedIconPath.replacingOccurrences(of: "%(theme)s", with: "OSX")
        self.init(contentsOfFile: path)
    }
    
    convenience init(withImage source: NSImage, resizedTo size: CGSize) {
        precondition(size.height >= 0, "size.height must be >= 0.")
        precondition(size.width >= 0, "size.width must be >= 0.")
        self.init(size: size)
        self.lockFocus()
        source.draw(in: NSRect(origin: CGPoint.zero, size: size),
                    from: NSRect(origin: CGPoint.zero, size: source.size),
                    operation: .sourceOver,
                    fraction: CGFloat(1))
        self.unlockFocus()
    }
}
