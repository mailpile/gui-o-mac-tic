import Foundation

class PostURL: URLCommand {
    let url: URL
    let payload: Data
    
    init(url: URL, payload: Data) {
        self.url = url
        self.payload = payload
    }
    
    func execute(sender: NSObject) {
        var request = URLRequest(url: self.url)
        request.httpMethod = "POST"
        request.httpBody = payload
        request.cachePolicy = .reloadIgnoringLocalAndRemoteCacheData
        
        let task = URLSession.shared.dataTask(with: request,
                                              completionHandler:completionHandler(data:urlResponse:error:))
        task.resume()
    }
}
