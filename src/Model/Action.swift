import Foundation

struct Action {
    let label: String?
    let item: String!
    let type: ActionType?
    let args: Args
    let sensitive: Bool?
    let op: Operation?
    let position: Position?
    let separator: Bool?
}
