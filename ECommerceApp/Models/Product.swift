import Foundation

struct ProductResponse: Codable {
    let id: Int
    let name: String
    let sku: String
    let price: Double
    let stockQuantity: Int
    let active: Bool
    let categoryId: Int?
    let categoryName: String?
    let createdAt: String?
    let updatedAt: String?
}

struct ProductRequest: Codable {
    let name: String
    let sku: String
    let price: Double
    let stockQuantity: Int
    let active: Bool
    let categoryId: Int?
}
