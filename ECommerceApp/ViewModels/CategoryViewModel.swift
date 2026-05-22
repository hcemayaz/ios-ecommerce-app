import Foundation

protocol CategoryViewModelDelegate: AnyObject {
    func didUpdateCategories()
    func didFailWithError(_ error: NetworkError)
    func didDeleteCategory()
}

final class CategoryViewModel {

    weak var delegate: CategoryViewModelDelegate?

    private(set) var categories: [CategoryResponse] = []
    private(set) var isLoading = false

    private let network = NetworkManager.shared

    func fetchCategories() {
        isLoading = true
        network.get(APIConstants.Endpoints.categories) { [weak self] (result: Result<[CategoryResponse], NetworkError>) in
            guard let self else { return }
            self.isLoading = false
            switch result {
            case .success(let categories):
                self.categories = categories
                DispatchQueue.main.async { self.delegate?.didUpdateCategories() }
            case .failure(let error):
                DispatchQueue.main.async { self.delegate?.didFailWithError(error) }
            }
        }
    }

    func createCategory(_ request: CategoryRequest) {
        network.post(APIConstants.Endpoints.categories, body: request) { [weak self] (result: Result<CategoryResponse, NetworkError>) in
            guard let self else { return }
            switch result {
            case .success:
                self.fetchCategories()
            case .failure(let error):
                DispatchQueue.main.async { self.delegate?.didFailWithError(error) }
            }
        }
    }

    func updateCategory(id: Int, request: CategoryRequest) {
        network.put("\(APIConstants.Endpoints.categories)/\(id)", body: request) { [weak self] (result: Result<CategoryResponse, NetworkError>) in
            guard let self else { return }
            switch result {
            case .success:
                self.fetchCategories()
            case .failure(let error):
                DispatchQueue.main.async { self.delegate?.didFailWithError(error) }
            }
        }
    }

    func deleteCategory(id: Int) {
        network.delete("\(APIConstants.Endpoints.categories)/\(id)") { [weak self] result in
            guard let self else { return }
            switch result {
            case .success:
                self.fetchCategories()
                DispatchQueue.main.async { self.delegate?.didDeleteCategory() }
            case .failure(let error):
                DispatchQueue.main.async { self.delegate?.didFailWithError(error) }
            }
        }
    }
}
