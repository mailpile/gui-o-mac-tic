import Foundation

@objc protocol Command: AnyObject {
    @objc func execute(sender: NSObject) -> Bool
    var messageOnError: String { get set }
}
