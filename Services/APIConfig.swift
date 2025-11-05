import Foundation
import Combine

// MARK: - Configuration
struct APIConfig {
    // Replace with your actual site URL
    static let baseURL = "https://gread.fun"
    static let wpAPI = "\(baseURL)/wp-json/wp/v2"
    static let customAPI = "\(baseURL)/wp-json/gread/v1"
    
    static let jwtLogin = "\(baseURL)/wp-json/jwt-auth/v1/token"
      
      // Endpoint for BuddyPress registration
      // NOTE: This assumes you are using the BuddyPress REST API for signups.
      // If not, you must replace this with your custom registration endpoint.
      static let bpRegister = "\(baseURL)/wp-json/buddypress/v1/signup"
      
      // Custom endpoint you must create in WordPress to handle Apple Sign In
      // This endpoint will receive the Apple token, validate it, and create/log in the user.
      static let appleSignIn = "\(baseURL)/wp-json/gread/v1/apple-signin"
}
