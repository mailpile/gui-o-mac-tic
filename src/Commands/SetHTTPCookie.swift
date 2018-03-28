import Foundation

class SetHTTPCookie: Command {
    let domain: String
    let key: String
    let value: String?
    let remove: Bool?
    
    init(_ domain: String, _ key: String, _ value: String?, _ remove: Bool?) {
        self.domain = domain
        self.key = key
        self.value = value
        self.remove = remove
    }
    
    func execute(sender: NSObject) {
        guard var cookies = Config.shared.http_cookies else {
            preconditionFailure("Attempted to modify a cookie, but no cookies exist.")
        }
        
        guard let indexOfCookieToModify = cookies.index(where: {
            $0.host == self.domain && $0.data.keys.contains(self.key)
        }) else {
            preconditionFailure("Failed to modify a non-existing cookie.")
        }
        
        if self.value != nil {
            cookies[indexOfCookieToModify].data[self.key] = value
        }
        
        if self.remove == true {
            cookies[indexOfCookieToModify].data.removeValue(forKey: self.key)
        }
    }
}
