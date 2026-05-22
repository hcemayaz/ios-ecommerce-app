import Foundation

protocol CustomerViewModelDelegate: AnyObject {
    func didUpdateCustomers()
    func didSelectCustomer(_ customer: CustomerResponse)
    func didFailWithError(_ error: NetworkError)
    func didDeleteCustomer()
}

final class CustomerViewModel {

    weak var delegate: CustomerViewModelDelegate?

    private(set) var customers: [CustomerResponse] = []
    private(set) var isLoading = false

    private let network = NetworkManager.shared

    func fetchCustomers() {
        isLoading = true
        network.get(APIConstants.Endpoints.customers) { [weak self] (result: Result<[CustomerResponse], NetworkError>) in
            guard let self else { return }
            self.isLoading = false
            switch result {
            case .success(let customers):
                self.customers = customers
                DispatchQueue.main.async { self.delegate?.didUpdateCustomers() }
            case .failure(let error):
                DispatchQueue.main.async { self.delegate?.didFailWithError(error) }
            }
        }
    }

    func fetchCustomer(id: Int) {
        network.get("\(APIConstants.Endpoints.customers)/\(id)") { [weak self] (result: Result<CustomerResponse, NetworkError>) in
            guard let self else { return }
            switch result {
            case .success(let customer):
                DispatchQueue.main.async { self.delegate?.didSelectCustomer(customer) }
            case .failure(let error):
                DispatchQueue.main.async { self.delegate?.didFailWithError(error) }
            }
        }
    }

    func createCustomer(_ request: CustomerRequest) {
        network.post(APIConstants.Endpoints.customers, body: request) { [weak self] (result: Result<CustomerResponse, NetworkError>) in
            guard let self else { return }
            switch result {
            case .success:
                self.fetchCustomers()
            case .failure(let error):
                DispatchQueue.main.async { self.delegate?.didFailWithError(error) }
            }
        }
    }

    func updateCustomer(id: Int, request: CustomerRequest) {
        network.put("\(APIConstants.Endpoints.customers)/\(id)", body: request) { [weak self] (result: Result<CustomerResponse, NetworkError>) in
            guard let self else { return }
            switch result {
            case .success:
                self.fetchCustomers()
            case .failure(let error):
                DispatchQueue.main.async { self.delegate?.didFailWithError(error) }
            }
        }
    }

    func deleteCustomer(id: Int) {
        network.delete("\(APIConstants.Endpoints.customers)/\(id)") { [weak self] result in
            guard let self else { return }
            switch result {
            case .success:
                self.fetchCustomers()
                DispatchQueue.main.async { self.delegate?.didDeleteCustomer() }
            case .failure(let error):
                DispatchQueue.main.async { self.delegate?.didFailWithError(error) }
            }
        }
    }
}
