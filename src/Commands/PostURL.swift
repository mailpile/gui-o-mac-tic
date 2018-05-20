import Foundation

class PostURL: URLCommand {
    var messageOnError: String = Blackboard.shared.nextErrorMessage
        ?? "Failed to execute 'post_url'."
    
    let url: URL
    let payload: Data?
    let cookies: [String: String]?
    
    init(url: URL, payload: Data?, cookies: [String: String]?) {
        self.url = url
        self.payload = payload
        self.cookies = cookies
    }
    
    func execute(sender: NSObject) {
        var request = URLRequest(url: self.url)
        request.httpMethod = "POST"
        request.httpBody = payload
        request.cachePolicy = .reloadIgnoringLocalAndRemoteCacheData
        
        if let cookies = self.cookies {
            for cookie in cookies {
                request.addValue(cookie.key + "=" + cookie.value, forHTTPHeaderField: "Cookie")
            }
        }
        
        let task = URLSession.shared.dataTask(with: request,
                                              completionHandler:completionHandler(data:urlResponse:error:))
        task.resume()
    }
}
