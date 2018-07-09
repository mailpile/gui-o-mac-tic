import Foundation

class SetHTTPCookie: Command {
    var messageOnError: String = Blackboard.shared.nextErrorMessage
        ?? "Failed to execute 'set_http_cookie'."
    
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
    
    func execute(sender: NSObject) -> Bool {
        guard var cookies = Blackboard.shared.config!.http_cookies else {
            assertionFailure("Attempted to modify a cookie, but no cookies exist.")
            return false
        }
        
        let domainParts = self.domain.split(separator: ":")
        precondition(domainParts.count == 1 || domainParts.count == 2)
        let host = String(domainParts.first!)
        let port: UInt16 = (domainParts.last == nil ? 80 : UInt16(String(domainParts.last!))!)
        
        let indexOfCookieToModify = cookies.index(where: {
                $0.host == host
                && $0.port == port
                && $0.data.keys.contains(self.key)
        })
        if indexOfCookieToModify == nil && (self.value != nil || self.remove == true) {
            assertionFailure("Failed to modify a non-existing cookie.")
            return false
        } else {
            if self.value != nil {
                cookies[indexOfCookieToModify!].data[self.key] = value
            }
            
            if self.remove == true {
                cookies[indexOfCookieToModify!].data.removeValue(forKey: self.key)
            }
        }
        return true
    }
}
