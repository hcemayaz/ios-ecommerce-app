import Foundation

enum OrderStatus: String, Codable {
    case PENDING
    case SHIPPED
    case DELIVERED
    case CANCELLED
}

struct OrderResponse: Codable {
    let id: Int
    let customerId: Int
    let customerName: String
    let totalAmount: Double
    let status: OrderStatus
    let createdAt: String?
    let items: [OrderItemResponse]
}

struct OrderItemResponse: Codable {
    let id: Int
    let productId: Int
    let productName: String
    let quantity: Int
    let unitPrice: Double
    let lineTotal: Double
}

struct OrderRequest: Codable {
    let customerId: Int
    let items: [OrderItemRequest]
}

struct OrderItemRequest: Codable {
    let productId: Int
    let quantity: Int
}
