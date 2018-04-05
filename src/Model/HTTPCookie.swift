import Foundation

class MPHTTPCookie {
    let host: String
    var data: [String: Any]

    init(hostname: String, json: [String: Any]) {
        self.host = hostname
        self.data = json
    }
}
