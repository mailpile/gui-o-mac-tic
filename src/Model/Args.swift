import Foundation

let URL_KEY = "_url"

@objc class Args: NSObject {
    private enum ArgsType {
        case none
        case string
        case list
        case dictionary
    }
    private let type: ArgsType
    let string: String?
    let list: [String]?
    let dictionary: [String: Any]?
    
    init(string: String?, list: [String]?, dictionary: [String: Any]?) {
        /* TODO error checking: xor shall be true between:
         string, list and dictionary.*/
        precondition( (string != nil) ^^ (list != nil) ^^ (dictionary != nil) )
        
        if string != nil {
            self.type = .string
            self.string = string
            self.list = nil
            self.dictionary = nil
        } else {
            self.string = nil
            if list != nil && list!.count > 0 {
                self.type = .list
                self.list = list
                self.dictionary = nil
            } else {
                self.list = nil
                if dictionary != nil && dictionary!.count > 0 {
                    self.type = .dictionary
                    self.dictionary = dictionary
                } else {
                    self.dictionary = nil
                    self.type = .none
                }
            }
        }
    }
    
    func asURL() -> URL? {
        switch self.type {
        case .none:
            return nil
        case .string:
            assert(self.string != nil)
            return URL.init(string: self.string!)
        case .list:
            assert(self.list!.count == 1)
            return URL.init(string: self.list!.first!)
        case .dictionary:
            assert(self.dictionary!.count == 1)
            if let urlString = self.dictionary![URL_KEY] {
                return URL.init(string: urlString as! String)
            }
        }
        return nil
    }
    
}
