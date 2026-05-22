import Foundation

protocol AssistantViewModelDelegate: AnyObject {
    func didReceiveResponse(_ response: AssistantResponse)
    func didFailWithError(_ error: NetworkError)
}

final class AssistantViewModel {

    weak var delegate: AssistantViewModelDelegate?

    private(set) var isLoading = false
    private let network = NetworkManager.shared

    func sendMessage(_ message: String) {
        isLoading = true
        let request = AssistantRequest(message: message)
        network.post(APIConstants.Endpoints.assistant, body: request) { [weak self] (result: Result<AssistantResponse, NetworkError>) in
            guard let self else { return }
            self.isLoading = false
            switch result {
            case .success(let response):
                DispatchQueue.main.async { self.delegate?.didReceiveResponse(response) }
            case .failure(let error):
                DispatchQueue.main.async { self.delegate?.didFailWithError(error) }
            }
        }
    }
}
