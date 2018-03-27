import Foundation

struct Action {
    var label: String?
    let id: String? // Id is optional because seperators do not have IDs.
    let type: ActionType?
    let args: Args?
    var sensitive: Bool?
    let op: Operation?
    let position: Position?
    let separator: Bool?
}
