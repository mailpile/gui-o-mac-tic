import Foundation

enum NetworkError: Error {
    case getaddrinfo(errorMessage: String)
    case socket(errorMessage: String)
    case bind(recoverable: Bool, errorMessage: String)
    case listen(recoverable: Bool, errorMessage: String)
    case accept(recoverable: Bool, errorMessage: String)
}
