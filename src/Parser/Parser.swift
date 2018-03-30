import Foundation

class Parser {
    
    static func parse(jsonConfig: URL) throws -> Config {
        let data: Data?
        let jsonObject: [String: Any]
        do {
            try data = Data(contentsOf: jsonConfig)
            try jsonObject = JSONSerialization.jsonObject(with: data!, options: []) as! [String: Any]
            let config = Config.init(json: jsonObject)!
            return config
        } catch {
            print(error) // TODO error handling.
            throw error
        }
    }
    
    static func parse(actions: [[String: Any]]) -> [ActionItem] {
        var result = [ActionItem]()
        for action in actions {
            let action = ActionItem(json: action)!
            result.append(action)
        }
        return result
    }

}
