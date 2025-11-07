import Foundation
import Combine

// MARK: - Configuration
struct APIConfig {
    // Replace with your actual site URL
    static let baseURL = "https://gread.fun"
    static let wpAPI = "\(baseURL)/wp-json/wp/v2"
    static let customAPI = "\(baseURL)/wp-json/gread/v1"
}
