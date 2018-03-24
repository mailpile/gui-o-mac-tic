import Foundation

@objc class Args: NSObject {
    let string: String?
    let list: [String]?
    let dictionary: [String: String]?
    
    init(string: String?, list: [String]?, dictionary: [String: String]?) {
        /* TODO error checking: xor shall be true between:
         string, list and dictionary.*/
        self.string = string
        self.list = list
        self.dictionary = dictionary
    }
}
