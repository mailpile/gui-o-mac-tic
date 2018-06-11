import Foundation

class MPHTTPCookie {
    let host: String
    let port: UInt16
    var data: [String: Any]

    init(hostname: String, port: UInt16, json: [String: Any]) {
        self.host = hostname
        self.port = port
        self.data = json
    }
}
