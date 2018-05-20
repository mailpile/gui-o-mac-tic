import Foundation

@objc protocol Command: AnyObject {
    @objc func execute(sender: NSObject)
    var messageOnError: String { get set }
}
