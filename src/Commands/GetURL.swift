import Foundation

class GetURL: URLCommand {
    var messageOnError: String = Blackboard.shared.nextErrorMessage
        ?? "Failed to execute 'get_url'."
    
    let url: URL
    let cookies: [String: String]?
    
    init(url: URL, cookies: [String: String]?) {
        self.url = url
        self.cookies = cookies
    }
    
    func execute(sender: NSObject) -> Bool {
        var request = URLRequest(url: self.url)
        
        if let cookies = self.cookies {
            for cookie in cookies {
                request.addValue(cookie.key + "=" + cookie.value, forHTTPHeaderField: "Cookie")
            }
        }
        
        let task = URLSession.shared.dataTask(with: request,
                                              completionHandler:completionHandler(data:urlResponse:error:))
        task.resume()
        return true
    }
}
