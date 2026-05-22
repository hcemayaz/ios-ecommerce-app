import Foundation

struct AssistantRequest: Codable {
    let message: String
}

struct AssistantResponse: Codable {
    let answer: String
    let recommendedProducts: [ProductResponse]?
}
