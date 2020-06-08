import Foundation

struct UserAPIResponse: Codable {
    let results: [User]
}

struct User: Codable {
    let name: Name
    let email: String
}

struct Name: Codable {
    let first: String
    let last: String
}
