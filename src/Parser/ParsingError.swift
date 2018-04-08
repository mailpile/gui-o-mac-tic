import Foundation

/** Error codes used by `Parser` to distinguish between different causes of failure. */
enum ParsingError: Error {
    
    /** The Stage 1 config is empty. */
    case empty
    
    /** The provided Stage 1 config is not an UTF-8 encoded JSON file. */
    case notJSON
    
    /** The provided Stage 1 config does not conform to GUI-o-Matic's protocol. */
    case nonCompliantInput
}
