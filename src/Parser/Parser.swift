import Foundation

class Parser {
    static func parse(json: String) throws -> Config {
        do {
            let data = json.data(using: String.Encoding.utf8)
            let jsonObject: [String: Any]
            try jsonObject = JSONSerialization.jsonObject(with: data!, options: []) as! [String: Any]
            let config = Config.init(json: jsonObject)!
            return config
        } catch {
            print(error) // TODO error handling
            throw error
        }
    }
    
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
            let action: ActionItem = parse(action: action)
            result.append(action)
        }
        return result
    }
    
    static func parse(action: [String: Any]) -> ActionItem {
        return ActionItem(json: action)!
    }
    
    static func parse(action: [String: Any]) -> Command {
        let action: ActionItem = parse(action: action)
        let command = CommandFactory.build(forOperation: action.op!, withArgs: action.args)
        return command
    }

}
