import Foundation

protocol ProductViewModelDelegate: AnyObject {
    func didUpdateProducts()
    func didSelectProduct(_ product: ProductResponse)
    func didFailWithError(_ error: NetworkError)
    func didDeleteProduct()
}

final class ProductViewModel {

    weak var delegate: ProductViewModelDelegate?

    private(set) var products: [ProductResponse] = []
    private(set) var isLoading = false

    private let network = NetworkManager.shared

    // MARK: - CRUD

    func fetchProducts() {
        isLoading = true
        network.get(APIConstants.Endpoints.products) { [weak self] (result: Result<[ProductResponse], NetworkError>) in
            guard let self else { return }
            self.isLoading = false
            switch result {
            case .success(let products):
                self.products = products
                DispatchQueue.main.async { self.delegate?.didUpdateProducts() }
            case .failure(let error):
                DispatchQueue.main.async { self.delegate?.didFailWithError(error) }
            }
        }
    }

    func fetchProduct(id: Int) {
        network.get("\(APIConstants.Endpoints.products)/\(id)") { [weak self] (result: Result<ProductResponse, NetworkError>) in
            guard let self else { return }
            switch result {
            case .success(let product):
                DispatchQueue.main.async { self.delegate?.didSelectProduct(product) }
            case .failure(let error):
                DispatchQueue.main.async { self.delegate?.didFailWithError(error) }
            }
        }
    }

    func createProduct(_ request: ProductRequest) {
        network.post(APIConstants.Endpoints.products, body: request) { [weak self] (result: Result<ProductResponse, NetworkError>) in
            guard let self else { return }
            switch result {
            case .success:
                self.fetchProducts()
            case .failure(let error):
                DispatchQueue.main.async { self.delegate?.didFailWithError(error) }
            }
        }
    }

    func updateProduct(id: Int, request: ProductRequest) {
        network.put("\(APIConstants.Endpoints.products)/\(id)", body: request) { [weak self] (result: Result<ProductResponse, NetworkError>) in
            guard let self else { return }
            switch result {
            case .success:
                self.fetchProducts()
            case .failure(let error):
                DispatchQueue.main.async { self.delegate?.didFailWithError(error) }
            }
        }
    }

    func deleteProduct(id: Int) {
        network.delete("\(APIConstants.Endpoints.products)/\(id)") { [weak self] result in
            guard let self else { return }
            switch result {
            case .success:
                self.fetchProducts()
                DispatchQueue.main.async { self.delegate?.didDeleteProduct() }
            case .failure(let error):
                DispatchQueue.main.async { self.delegate?.didFailWithError(error) }
            }
        }
    }
}
