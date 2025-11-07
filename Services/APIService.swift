import Foundation

class APIService {
    static let shared = APIService()
    
    private init() {}
    
    func fetchBooks(page: Int) async throws -> [Book] {
        let url = URL(string: "\(APIConfig.wpAPI)/book?per_page=20&page=\(page)")!
        let (data, _) = try await URLSession.shared.data(from: url)
        let books = try JSONDecoder().decode([Book].self, from: data)
        return books
    }
    
    func searchBooks(query: String) async throws -> [Book] {
        var components = URLComponents(string: "\(APIConfig.wpAPI)/book")!
        components.queryItems = [
            URLQueryItem(name: "search", value: query),
            URLQueryItem(name: "per_page", value: "20")
        ]
        
        guard let url = components.url else {
            throw NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"])
        }
        
        let (data, _) = try await URLSession.shared.data(from: url)
        let books = try JSONDecoder().decode([Book].self, from: data)
        return books
    }
    
    func addBookToLibrary(bookId: Int, token: String) async throws {
        let url = URL(string: "\(APIConfig.customAPI)/library/add")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body: [String: Int] = ["book_id": bookId]
        request.httpBody = try JSONEncoder().encode(body)
        
        let (_, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            throw NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to add book"])
        }
    }
    
    func fetchUserBooks(token: String) async throws -> [UserBook] {
        let url = URL(string: "\(APIConfig.customAPI)/library")!
        var request = URLRequest(url: url)
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        let (data, _) = try await URLSession.shared.data(for: request)
        
        guard let json = try JSONSerialization.jsonObject(with: data) as? [[String: Any]] else {
            return []
        }
        
        return json.compactMap { item in
            guard let bookId = item["book_id"] as? Int,
                  let currentPage = item["current_page"] as? Int,
                  let status = item["status"] as? String else {
                return nil
            }
            
            let bookData = item["book"] as? [String: Any]
            let title = bookData?["title"] as? String ?? "Unknown"
            
            let book = Book(
                id: bookId,
                title: title,
                author: bookData?["author"] as? String,
                isbn: bookData?["isbn"] as? String,
                pageCount: bookData?["page_count"] as? Int,
                content: bookData?["content"] as? String
            )
            
            return UserBook(
                id: item["id"] as? Int ?? bookId,
                book: book,
                currentPage: currentPage,
                status: status
            )
        }
    }
    
    func updateProgress(bookId: Int, currentPage: Int, token: String) async throws {
        let url = URL(string: "\(APIConfig.customAPI)/library/progress")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body: [String: Int] = [
            "book_id": bookId,
            "current_page": currentPage
        ]
        request.httpBody = try JSONEncoder().encode(body)
        
        let (_, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            throw NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to update progress"])
        }
    }
    
    func fetchUserStats(userId: Int, token: String) async throws -> UserStats {
        let url = URL(string: "\(APIConfig.customAPI)/user/\(userId)/stats")!
        var request = URLRequest(url: url)
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        let (data, _) = try await URLSession.shared.data(for: request)
        let stats = try JSONDecoder().decode(UserStats.self, from: data)
        return stats
    }
    
    func fetchActivityFeed(page: Int, token: String?) async throws -> [ActivityItem] {
        var components = URLComponents(string: "\(APIConfig.baseURL)/wp-json/buddypress/v1/activity")!
        components.queryItems = [
            URLQueryItem(name: "page", value: "\(page)"),
            URLQueryItem(name: "per_page", value: "20")
        ]
        
        guard let url = components.url else {
            throw NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"])
        }
        
        var request = URLRequest(url: url)
        if let token = token {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        
        let (data, _) = try await URLSession.shared.data(for: request)
        
        let decoder = JSONDecoder()
        let activities = try decoder.decode([BuddyPressActivity].self, from: data)
        
        return activities.map { activity in
            ActivityItem(
                id: activity.id,
                userId: activity.user_id,
                content: activity.content.rendered,
                date: activity.date,
                type: activity.type,
                userName: activity.user?.name
            )
        }
    }
    
    func postActivityUpdate(content: String, token: String) async throws {
        let url = URL(string: "\(APIConfig.baseURL)/wp-json/buddypress/v1/activity")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body: [String: String] = ["content": content]
        request.httpBody = try JSONEncoder().encode(body)
        
        let (_, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            throw NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to post update"])
        }
    }
    
    func fetchGroups(token: String?) async throws -> [Group] {
        let url = URL(string: "\(APIConfig.baseURL)/wp-json/buddypress/v1/groups")!
        var request = URLRequest(url: url)
        if let token = token {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        
        let (data, _) = try await URLSession.shared.data(for: request)
        let decoder = JSONDecoder()
        let groups = try decoder.decode([Group].self, from: data)
        return groups
    }
    
    func removeBookFromLibrary(bookId: Int, token: String) async throws {
        let url = URL(string: "\(APIConfig.customAPI)/library/remove")!
        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body: [String: Int] = ["book_id": bookId]
        request.httpBody = try JSONEncoder().encode(body)
        
        let (_, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            throw NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to remove book"])
        }
    }
    
    func fetchLeaderboard(type: String, limit: Int = 15) async throws -> [LeaderboardEntry] {
        return []
    }
    
    func reportUser(userId: Int, reason: String, description: String, token: String) async throws {
        let url = URL(string: "\(APIConfig.customAPI)/report/user")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body: [String: Any] = [
            "user_id": userId,
            "reason": reason,
            "description": description
        ]
        request.httpBody = try JSONSerialization.data(withJSONObject: body)
        
        let (_, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            throw NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to submit report"])
        }
    }
}

struct BuddyPressActivity: Codable {
    let id: Int
    let user_id: Int
    let content: RenderedContent
    let date: String
    let type: String
    let user: BPUser?
    
    struct RenderedContent: Codable {
        let rendered: String
    }
    
    struct BPUser: Codable {
        let name: String
    }
}
