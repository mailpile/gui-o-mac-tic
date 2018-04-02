import Foundation

enum NetworkError: Error {
    case getaddrinfo(reason: String)
    case socket(reason: String)
}
