import Foundation

class Parser {
    /**
     Parses a stage 1 configuration.
     - Parameter json: A valid UTF-8 encoded JSON document containing a Stage 1 configuration. The document must conforms to GUI-o-Matic's protocol. document
     - Throws: An error of type `ParsingError.empty` if `json` is empty.
     - Returns: An corresponding domain model instance of the parsed configuration.
     
     */
    static func parse(json: String) throws -> Config {
        func parse() throws -> [String: Any] {
            let data = json.data(using: String.Encoding.utf8)
            let jsonObject = try JSONSerialization.jsonObject(with: data!, options: []) as! [String: Any]
            return jsonObject
        }
        guard json.count > 0 else { throw ParsingError.empty }
        let jsonObject: [String: Any]
        do { try jsonObject = parse() } catch { throw ParsingError.notJSON }
        do { return try Config.init(json: jsonObject)! } catch { throw error }
    }
    
    static func parse(jsonConfig: URL) throws -> Config {
        let data: Data?
        let jsonObject: [String: Any]
        do {
            try data = Data(contentsOf: jsonConfig)
            try jsonObject = JSONSerialization.jsonObject(with: data!, options: []) as! [String: Any]
            let config = try Config.init(json: jsonObject)!
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
