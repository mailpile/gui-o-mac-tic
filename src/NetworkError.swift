import Foundation

enum NetworkError: Error {
    case getaddrinfo(recoverable: Bool, errorMessage: String, errorCode: Int32)
    case socket(recoverable: Bool,      errorMessage: String, errorCode: Int32)
    case bind(recoverable: Bool,        errorMessage: String, errorCode: Int32)
    case listen(recoverable: Bool,      errorMessage: String, errorCode: Int32)
    case accept(recoverable: Bool,      errorMessage: String, errorCode: Int32)
    case read(recoverable: Bool,        errorMessage: String, errorCode: Int32)
}
