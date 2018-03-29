import Foundation

struct FontStyles {
    struct FontStyle {
        let family: String?
        let points: Int?
        let bold: Bool?
        let italic: Bool?
    }
    
    let details: FontStyle?
    let notification: FontStyle?
    let splash: FontStyle?
    let status: FontStyle?
}
