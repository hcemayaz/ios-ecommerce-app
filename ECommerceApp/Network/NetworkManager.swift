import Foundation

final class NetworkManager {

    static let shared = NetworkManager()
    private let session: URLSession

    private init() {
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 30
        session = URLSession(configuration: config)
    }

    // MARK: - Generic GET

    func get<T: Decodable>(_ endpoint: String, completion: @escaping (Result<T, NetworkError>) -> Void) {
        request(endpoint: endpoint, method: "GET", body: nil as String?, completion: completion)
    }

    // MARK: - Generic POST

    func post<T: Decodable, B: Encodable>(_ endpoint: String, body: B, completion: @escaping (Result<T, NetworkError>) -> Void) {
        request(endpoint: endpoint, method: "POST", body: body, completion: completion)
    }

    // MARK: - Generic PUT

    func put<T: Decodable, B: Encodable>(_ endpoint: String, body: B, completion: @escaping (Result<T, NetworkError>) -> Void) {
        request(endpoint: endpoint, method: "PUT", body: body, completion: completion)
    }

    // MARK: - Generic PATCH

    func patch<T: Decodable, B: Encodable>(_ endpoint: String, body: B, completion: @escaping (Result<T, NetworkError>) -> Void) {
        request(endpoint: endpoint, method: "PATCH", body: body, completion: completion)
    }

    // MARK: - DELETE (no response body)

    func delete(_ endpoint: String, completion: @escaping (Result<Void, NetworkError>) -> Void) {
        guard let url = URL(string: APIConstants.baseURL + endpoint) else {
            completion(.failure(.invalidURL))
            return
        }

        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "DELETE"

        session.dataTask(with: urlRequest) { _, response, error in
            if let error = error {
                completion(.failure(.unknown(error)))
                return
            }
            if let httpResponse = response as? HTTPURLResponse,
               !(200...299).contains(httpResponse.statusCode) {
                completion(.failure(.serverError(httpResponse.statusCode)))
                return
            }
            completion(.success(()))
        }.resume()
    }

    // MARK: - Private

    private func request<T: Decodable, B: Encodable>(
        endpoint: String,
        method: String,
        body: B?,
        completion: @escaping (Result<T, NetworkError>) -> Void
    ) {
        guard let url = URL(string: APIConstants.baseURL + endpoint) else {
            completion(.failure(.invalidURL))
            return
        }

        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = method
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")

        if let body = body {
            do {
                urlRequest.httpBody = try JSONEncoder().encode(body)
            } catch {
                completion(.failure(.decodingError(error)))
                return
            }
        }

        session.dataTask(with: urlRequest) { data, response, error in
            if let error = error {
                completion(.failure(.unknown(error)))
                return
            }

            if let httpResponse = response as? HTTPURLResponse,
               !(200...299).contains(httpResponse.statusCode) {
                completion(.failure(.serverError(httpResponse.statusCode)))
                return
            }

            guard let data = data else {
                completion(.failure(.noData))
                return
            }

            do {
                let decoded = try JSONDecoder().decode(T.self, from: data)
                completion(.success(decoded))
            } catch {
                completion(.failure(.decodingError(error)))
            }
        }.resume()
    }
}
