import Foundation

protocol OrderViewModelDelegate: AnyObject {
    func didUpdateOrders()
    func didSelectOrder(_ order: OrderResponse)
    func didFailWithError(_ error: NetworkError)
    func didDeleteOrder()
}

final class OrderViewModel {

    weak var delegate: OrderViewModelDelegate?

    private(set) var orders: [OrderResponse] = []
    private(set) var isLoading = false

    private let network = NetworkManager.shared

    func fetchOrders() {
        isLoading = true
        network.get(APIConstants.Endpoints.orders) { [weak self] (result: Result<[OrderResponse], NetworkError>) in
            guard let self else { return }
            self.isLoading = false
            switch result {
            case .success(let orders):
                self.orders = orders
                DispatchQueue.main.async { self.delegate?.didUpdateOrders() }
            case .failure(let error):
                DispatchQueue.main.async { self.delegate?.didFailWithError(error) }
            }
        }
    }

    func fetchOrder(id: Int) {
        network.get("\(APIConstants.Endpoints.orders)/\(id)") { [weak self] (result: Result<OrderResponse, NetworkError>) in
            guard let self else { return }
            switch result {
            case .success(let order):
                DispatchQueue.main.async { self.delegate?.didSelectOrder(order) }
            case .failure(let error):
                DispatchQueue.main.async { self.delegate?.didFailWithError(error) }
            }
        }
    }

    func createOrder(_ request: OrderRequest) {
        network.post(APIConstants.Endpoints.orders, body: request) { [weak self] (result: Result<OrderResponse, NetworkError>) in
            guard let self else { return }
            switch result {
            case .success:
                self.fetchOrders()
            case .failure(let error):
                DispatchQueue.main.async { self.delegate?.didFailWithError(error) }
            }
        }
    }

    func updateOrderStatus(id: Int, status: OrderStatus) {
        let body = ["status": status.rawValue]
        network.patch("\(APIConstants.Endpoints.orders)/\(id)/status", body: body) { [weak self] (result: Result<OrderResponse, NetworkError>) in
            guard let self else { return }
            switch result {
            case .success:
                self.fetchOrders()
            case .failure(let error):
                DispatchQueue.main.async { self.delegate?.didFailWithError(error) }
            }
        }
    }

    func deleteOrder(id: Int) {
        network.delete("\(APIConstants.Endpoints.orders)/\(id)") { [weak self] result in
            guard let self else { return }
            switch result {
            case .success:
                self.fetchOrders()
                DispatchQueue.main.async { self.delegate?.didDeleteOrder() }
            case .failure(let error):
                DispatchQueue.main.async { self.delegate?.didFailWithError(error) }
            }
        }
    }
}
