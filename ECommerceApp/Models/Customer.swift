import Foundation

struct CustomerResponse: Codable {
    let id: Int
    let firstName: String
    let lastName: String
    let email: String
    let phone: String?
}

struct CustomerRequest: Codable {
    let firstName: String
    let lastName: String
    let email: String
    let phone: String?
}
