import Foundation

struct FontStyles {
    struct FontStyle {
        let family: String?
        let points: Int?
        let bold: Bool?
        let italic: Bool?
    }
    
    let title: FontStyle?
    let details: FontStyle?
    let notification: FontStyle?
    let splash: FontStyle?
    let buttons: FontStyle?
    
    /** Maps the id of a specific status to the fontstyle to be used for that status's title. */
    var statusId2statusTitle: [String: FontStyle] = [:]
    
    /** Maps the id of a specific status to the fontstyle to be used for that status's details. */
    var statusId2statusDetails: [String: FontStyle] = [:]
}
