import Foundation

struct ActionItem {
    var label: String? {
        didSet {
            NotificationCenter.default.post(name: Constants.DOMAIN_UPDATE, object: self)
        }
    }
    let id: String? // Id is optional because seperators and notify-action_items do not have IDs.
    let type: ActionItemType?
    let args: Args?
    var sensitive: Bool?
    let op: Operation?
    let position: Position?
    let separator: Bool?
}
