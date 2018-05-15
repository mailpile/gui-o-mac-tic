import Foundation

class CookieControl {
    static public func cookiesForHost(url: URL) -> [String: String] {
        var cookies = [String: String]()
        if let host = url.host {
            let HTTP = 80
            let port = url.port ?? HTTP
            if let http_cookies = Blackboard.shared.config?.http_cookies {
                for cookie in http_cookies {
                    if cookie.host == host && cookie.port == port {
                        for key in cookie.data.keys {
                            cookies[key] = cookie.data[key] as? String
                        }
                    }
                }
            }
        }
        return cookies
    }
}
