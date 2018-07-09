import Foundation

protocol URLCommand: Command {
    func completionHandler(data: Data?, urlResponse: URLResponse?, error: Error?)
    func execute(sender: NSObject) -> Bool
}

extension URLCommand {
    func completionHandler(data: Data?, urlResponse: URLResponse?, error: Error?) {
        guard error == nil else {
            // TODO Handle errors.
            return
        }
        
        guard let data = data else {
            // Nothing was returned.
            return
        }
        
        guard urlResponse?.mimeType == "application/json" else {
            // Ignoring a non-json reply.
            return
        }
        
        do {
            if let json = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? [String: Any] {
                let message = json["message"] as? String
                precondition(message != nil, "JSON replies shall contain a \"message\".")
                UserNotificationFacade.DeliverNotification(withText: message!)
            }
        } catch let error {
            // TODO Handle the error.
            assertionFailure("Not implemented. Error was: \(error.localizedDescription)")
        }
    }
}
