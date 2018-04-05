import Foundation

class GetURL: URLCommand {
    let url: URL
    
    init(url: URL) {
        self.url = url
    }
    
    func execute(sender: NSObject) {
        let request = URLRequest(url: self.url)
        let task = URLSession.shared.dataTask(with: request,
                                              completionHandler:completionHandler(data:urlResponse:error:))
        task.resume()
    }
}
