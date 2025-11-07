import Foundation

enum APIError: LocalizedError {
    case invalidURL
    case networkError(Error)
    case invalidResponse
    case decodingError(Error)
    case serverError(Int, String)
    case unauthorized
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid URL"
        case .networkError(let error):
            return "Network error: \(error.localizedDescription)"
        case .invalidResponse:
            return "Invalid server response"
        case .decodingError(let error):
            return "Failed to decode response: \(error.localizedDescription)"
        case .serverError(let code, let message):
            return "Server error (\(code)): \(message)"
        case .unauthorized:
            return "Unauthorized access"
        }
    }
}

class APIService {
    static let shared = APIService()
    private let session: URLSession
    
    private init() {
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 30
        config.timeoutIntervalForResource = 300
        self.session = URLSession(configuration: config)
    }
    
    // MARK: - Helper Methods
    
    private func createURL(endpoint: String) throws -> URL {
        guard let url = URL(string: APIConfig.baseURL + endpoint) else {
            throw APIError.invalidURL
        }
        return url
    }
    
    private func createRequest(url: URL, method: String = "GET", authRequired: Bool = false) -> URLRequest {
        var request = URLRequest(url: url)
        request.httpMethod = method
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        if authRequired, let token = UserDefaults.standard.string(forKey: "auth_token") {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        
        return request
    }
    
    private func handleResponse<T: Decodable>(_ data: Data, _ response: URLResponse) throws -> T {
        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.invalidResponse
        }
        
        guard (200...299).contains(httpResponse.statusCode) else {
            let errorMessage = String(data: data, encoding: .utf8) ?? "Unknown error"
            throw APIError.serverError(httpResponse.statusCode, errorMessage)
        }
        
        do {
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            decoder.dateDecodingStrategy = .iso8601
            return try decoder.decode(T.self, from: data)
        } catch {
            print("Decoding error: \(error)")
            print("Response data: \(String(data: data, encoding: .utf8) ?? "nil")")
            throw APIError.decodingError(error)
        }
    }
    
    
    
    // MARK: - Books
    
    func fetchBooks() async throws -> [Book] {
        let url = try createURL(endpoint: "/wp-json/gread/v1/books")
        let request = createRequest(url: url)
        
        do {
            let (data, response) = try await session.data(for: request)
            return try handleResponse(data, response)
        } catch let error as APIError {
            throw error
        } catch {
            throw APIError.networkError(error)
        }
    }
    
    func fetchBook(id: Int) async throws -> Book {
        let url = try createURL(endpoint: "/wp-json/gread/v1/books/\(id)")
        let request = createRequest(url: url)
        
        do {
            let (data, response) = try await session.data(for: request)
            return try handleResponse(data, response)
        } catch let error as APIError {
            throw error
        } catch {
            throw APIError.networkError(error)
        }
    }
    
    func searchBooks(query: String) async throws -> [Book] {
        let encodedQuery = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? query
        let url = try createURL(endpoint: "/wp-json/gread/v1/books?search=\(encodedQuery)")
        let request = createRequest(url: url)
        
        do {
            let (data, response) = try await session.data(for: request)
            return try handleResponse(data, response)
        } catch let error as APIError {
            throw error
        } catch {
            throw APIError.networkError(error)
        }
    }
    
    func addBook(title: String, author: String, pageCount: Int, genre: String?) async throws -> Book {
        let url = try createURL(endpoint: "/wp-json/gread/v1/books")
        var request = createRequest(url: url, method: "POST", authRequired: true)
        
        let body: [String: Any] = [
            "title": title,
            "author": author,
            "page_count": pageCount,
            "genre": genre ?? ""
        ]
        
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)
        
        do {
            let (data, response) = try await session.data(for: request)
            return try handleResponse(data, response)
        } catch let error as APIError {
            throw error
        } catch {
            throw APIError.networkError(error)
        }
    }
    
    // MARK: - User Books (Library)
    
    func fetchUserBooks() async throws -> [UserBook] {
        let url = try createURL(endpoint: "/wp-json/gread/v1/library")
        let request = createRequest(url: url, authRequired: true)
        
        do {
            let (data, response) = try await session.data(for: request)
            return try handleResponse(data, response)
        } catch let error as APIError {
            throw error
        } catch {
            throw APIError.networkError(error)
        }
    }
    
    func addBookToLibrary(bookId: Int, status: String) async throws -> UserBook {
        let url = try createURL(endpoint: "/wp-json/gread/v1/library")
        var request = createRequest(url: url, method: "POST", authRequired: true)
        
        let body: [String: Any] = [
            "book_id": bookId,
            "status": status
        ]
        
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)
        
        do {
            let (data, response) = try await session.data(for: request)
            return try handleResponse(data, response)
        } catch let error as APIError {
            throw error
        } catch {
            throw APIError.networkError(error)
        }
    }
    
    func updateUserBook(id: Int, status: String?, currentPage: Int?) async throws {
        let url = try createURL(endpoint: "/wp-json/gread/v1/library/\(id)")
        var request = createRequest(url: url, method: "PUT", authRequired: true)
        
        var body: [String: Any] = [:]
        if let status = status {
            body["status"] = status
        }
        if let currentPage = currentPage {
            body["current_page"] = currentPage
        }
        
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)
        
        do {
            let (data, response) = try await session.data(for: request)
            let _: [String: String] = try handleResponse(data, response)
        } catch let error as APIError {
            throw error
        } catch {
            throw APIError.networkError(error)
        }
    }
    
    func deleteUserBook(id: Int) async throws {
        let url = try createURL(endpoint: "/wp-json/gread/v1/library/\(id)")
        var request = createRequest(url: url, method: "DELETE", authRequired: true)
        
        do {
            let (data, response) = try await session.data(for: request)
            let _: [String: String] = try handleResponse(data, response)
        } catch let error as APIError {
            throw error
        } catch {
            throw APIError.networkError(error)
        }
    }
    
    // MARK: - User Stats
    
    func fetchUserStats() async throws -> UserStats {
        let url = try createURL(endpoint: "/wp-json/gread/v1/user-stats")
        let request = createRequest(url: url, authRequired: true)
        
        do {
            let (data, response) = try await session.data(for: request)
            return try handleResponse(data, response)
        } catch let error as APIError {
            throw error
        } catch {
            throw APIError.networkError(error)
        }
    }
    
    // MARK: - Activity Feed
    
    func fetchActivities(page: Int = 1) async throws -> [ActivityItem] {
        let url = try createURL(endpoint: "/wp-json/buddypress/v1/activity?page=\(page)&per_page=20")
        let request = createRequest(url: url)
        
        do {
            let (data, response) = try await session.data(for: request)
            
            // BuddyPress returns a structure with activities array
            struct ActivityResponse: Decodable {
                let activities: [ActivityItem]?
            }
            
            let activityResponse: ActivityResponse = try handleResponse(data, response)
            return activityResponse.activities ?? []
        } catch let error as APIError {
            throw error
        } catch {
            throw APIError.networkError(error)
        }
    }
    
    func createActivity(content: String) async throws {
        let url = try createURL(endpoint: "/wp-json/buddypress/v1/activity")
        var request = createRequest(url: url, method: "POST", authRequired: true)
        
        let body: [String: Any] = [
            "content": content,
            "component": "activity",
            "type": "activity_update"
        ]
        
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)
        
        do {
            let (_, response) = try await session.data(for: request)
            guard let httpResponse = response as? HTTPURLResponse,
                  (200...299).contains(httpResponse.statusCode) else {
                throw APIError.invalidResponse
            }
        } catch {
            throw APIError.networkError(error)
        }
    }
        
        // MARK: - Groups
        
    func fetchGroups(page: Int = 1) async throws -> [Group] {
        let url = try createURL(endpoint: "/wp-json/buddypress/v1/groups?page=\(page)&per_page=20")
        let request = createRequest(url: url)
        
        do {
            let (data, response) = try await session.data(for: request)
            
            struct GroupsResponse: Decodable {
                let groups: [Group]?
            }
            
            let groupsResponse: GroupsResponse = try handleResponse(data, response)
            return groupsResponse.groups ?? []
        } catch let error as APIError {
            throw error
        } catch {
            throw APIError.networkError(error)
        }
    }
        
    func joinGroup(groupId: Int) async throws {
        guard let userId = UserDefaults.standard.object(forKey: "user_id") as? Int else {
            throw APIError.unauthorized
        }
        
        let url = try createURL(endpoint: "/wp-json/buddypress/v1/groups/\(groupId)/members/\(userId)")
        var request = createRequest(url: url, method: "POST", authRequired: true)
        
        do {
            let (data, response) = try await session.data(for: request)
            let _: [String: String] = try handleResponse(data, response)
        } catch let error as APIError {
            throw error
        } catch {
            throw APIError.networkError(error)
        }
    }
    
    func leaveGroup(groupId: Int) async throws {
        guard let userId = UserDefaults.standard.object(forKey: "user_id") as? Int else {
            throw APIError.unauthorized
        }
        
        let url = try createURL(endpoint: "/wp-json/buddypress/v1/groups/\(groupId)/members/\(userId)")
        var request = createRequest(url: url, method: "DELETE", authRequired: true)
        
        do {
            let (data, response) = try await session.data(for: request)
            let _: [String: String] = try handleResponse(data, response)
        } catch let error as APIError {
            throw error
        } catch {
            throw APIError.networkError(error)
        }
    }

        // MARK: - Leaderboards
        
    func fetchLeaderboard() async throws -> Leaderboard {
        let url = try createURL(endpoint: "/wp-json/gread/v1/leaderboard")
        let request = createRequest(url: url)
        
        do {
            let (data, response) = try await session.data(for: request)
            return try handleResponse(data, response)
        } catch let error as APIError {
            throw error
        } catch {
            throw APIError.networkError(error)
        }
    }
    }


extension APIService {
    
    func reportUser(userId: Int, reason: String, token: String) async throws {
        let url = try createURL(endpoint: "/wp-json/gread/v1/report-user")
        var request = createRequest(url: url, method: "POST", authRequired: true)
        
        let body: [String: Any] = [
            "user_id": userId,
            "reason": reason
        ]
        
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)
        
        do {
            let (data, response) = try await session.data(for: request)
            let _: [String: String] = try handleResponse(data, response)
        } catch let error as APIError {
            throw error
        } catch {
            throw APIError.networkError(error)
        }
    }
}
