import Foundation

class ConfigParser {
    
    static func parse(file: URL) throws -> Config {
        
        let data: Data?
        let jsonObject: [String: Any]
        do {
            try data = Data(contentsOf: file)
            try jsonObject = JSONSerialization.jsonObject(with: data!, options: []) as! [String: Any]
            let config = Config.init(json: jsonObject)!
            return config
        } catch {
            print(error) // TODO error handling.
            throw error
        }
    }

}
