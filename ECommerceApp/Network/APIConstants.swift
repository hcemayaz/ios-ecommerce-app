import Foundation

enum APIConstants {
    static let baseURL = "http://localhost:8080/api"

    enum Endpoints {
        static let products = "/products"
        static let categories = "/categories"
        static let customers = "/customers"
        static let orders = "/orders"
        static let assistant = "/assistant/chat"
    }
}
