import Foundation

@objc protocol Command: AnyObject {
    @objc func execute(sender: NSObject)
}
