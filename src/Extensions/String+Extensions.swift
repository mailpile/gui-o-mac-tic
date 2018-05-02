import Foundation

extension String {
    private static let hexChars = CharacterSet.init(charactersIn: "0123456789ABCDEF")
    func isHex() -> Bool {
        return uppercased().rangeOfCharacter(from: String.hexChars) != nil
    }
    
    /**
     Checks if a string is nil or empty.
 
     - Parameter string: The parameter to be checked.
     - Returns: `true` if the parameter is nil or if it does not consist of any characters; `false` otherwise.
     */
    static func isNeitherNilNorEmpty(_ string: String?) -> Bool {
        return string != nil && !string!.isEmpty
    }
}
