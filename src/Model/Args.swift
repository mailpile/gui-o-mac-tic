import Foundation

@objc class Args: NSObject {
    let string: String?
    let list: [String]?
    let dictionary: [String: String]?
    
    init(string: String?, list: [String]?, dictionary: [String: String]?) {
        self.string = string
        self.list = list
        self.dictionary = dictionary
    }
}
