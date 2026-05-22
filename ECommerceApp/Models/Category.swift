import Foundation

struct CategoryResponse: Codable {
    let id: Int
    let name: String
    let parentId: Int?
}

struct CategoryRequest: Codable {
    let name: String
    let parentId: Int?
}
