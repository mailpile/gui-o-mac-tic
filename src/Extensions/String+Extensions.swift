import Foundation

extension String {
    private static let hexChars = CharacterSet.init(charactersIn: "0123456789ABCDEF")
    func isHex() -> Bool {
        return uppercased().rangeOfCharacter(from: String.hexChars) != nil
    }
}
