import Foundation

struct ActionItem {
    var label: String?
    let id: String? // Id is optional because seperators do not have IDs.
    let type: ActionItemType?
    let args: Args?
    var sensitive: Bool?
    let op: Operation?
    let position: Position?
    let separator: Bool?
}
