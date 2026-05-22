import Foundation

enum NetworkError: LocalizedError {
    case invalidURL
    case noData
    case decodingError(Error)
    case serverError(Int)
    case unknown(Error)

    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Geçersiz URL"
        case .noData:
            return "Veri bulunamadı"
        case .decodingError(let error):
            return "JSON parse hatası: \(error.localizedDescription)"
        case .serverError(let code):
            return "Sunucu hatası: \(code)"
        case .unknown(let error):
            return "Bilinmeyen hata: \(error.localizedDescription)"
        }
    }
}
