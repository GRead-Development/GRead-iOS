import Foundation

class APIService {
    static let shared = APIService()
    
    private init() {}
    
    // MARK: - Books
    
    func fetchBooks(page: Int = 1) async throws -> [Book] {
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
    
    // MARK: - Library Management
    
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
        
        return json.compactMap { item -> UserBook? in
            guard let bookId = item["book_id"] as? Int ?? (item["book"] as? [String: Any])?["id"] as? Int,
                  let currentPage = item["current_page"] as? Int,
                  let status = item["status"] as? String,
                  let bookData = item["book"] as? [String: Any],
                  let title = bookData["title"] as? String else {
                return nil
            }
            
            let book = Book(
                id: bookId,
                title: title,
                author: bookData["author"] as? String,
                isbn: bookData["isbn"] as? String,
                pageCount: bookData["page_count"] as? Int,
                content: bookData["content"] as? String
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
    
    // MARK: - User Stats
    
    func fetchUserStats(userId: Int, token: String) async throws -> UserStats {
        let url = URL(string: "\(APIConfig.customAPI)/user/\(userId)/stats")!
        
        var request = URLRequest(url: url)
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        let (data, _) = try await URLSession.shared.data(for: request)
        let stats = try JSONDecoder().decode(UserStats.self, from: data)
        
        return stats
    }
    
    // MARK: - Activity Feed (FIXED)
    
    func fetchActivityFeed(page: Int, token: String?) async throws -> [ActivityItem] {
        var components = URLComponents(string: "\(APIConfig.customAPI)/activity")!
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
        
        // Parse the response which includes activities array
        guard let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
              let activitiesArray = json["activities"] as? [[String: Any]] else {
            return []
        }
        
        return activitiesArray.compactMap { activityDict -> ActivityItem? in
            guard let id = activityDict["id"] as? Int,
                  let userId = activityDict["user_id"] as? Int,
                  let userName = activityDict["user_name"] as? String,
                  let content = activityDict["content"] as? String,
                  let action = activityDict["action"] as? String,
                  let date = activityDict["date"] as? String,
                  let type = activityDict["type"] as? String else {
                return nil
            }
            
            let dateFormatted = activityDict["date_formatted"] as? String
            let avatarUrl = activityDict["avatar_url"] as? String
            
            return ActivityItem(
                id: id,
                userId: userId,
                userName: userName,
                avatarUrl: avatarUrl,
                content: content,
                action: action,
                date: date,
                type: type,
                dateFormatted: dateFormatted
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
    
    // MARK: - User Moderation
    
    func blockUser(userId: Int, token: String) async throws {
        let url = URL(string: "\(APIConfig.customAPI)/user/block")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body: [String: Int] = ["user_id": userId]
        request.httpBody = try JSONEncoder().encode(body)
        
        let (_, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            throw NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to block user"])
        }
    }
    
    func unblockUser(userId: Int, token: String) async throws {
        let url = URL(string: "\(APIConfig.customAPI)/user/unblock")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body: [String: Int] = ["user_id": userId]
        request.httpBody = try JSONEncoder().encode(body)
        
        let (_, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            throw NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to unblock user"])
        }
    }
    
    func muteUser(userId: Int, token: String) async throws {
        let url = URL(string: "\(APIConfig.customAPI)/user/mute")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body: [String: Int] = ["user_id": userId]
        request.httpBody = try JSONEncoder().encode(body)
        
        let (_, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            throw NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to mute user"])
        }
    }
    
    func unmuteUser(userId: Int, token: String) async throws {
        let url = URL(string: "\(APIConfig.customAPI)/user/unmute")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body: [String: Int] = ["user_id": userId]
        request.httpBody = try JSONEncoder().encode(body)
        
        let (_, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            throw NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to unmute user"])
        }
    }
    
    func reportUser(userId: Int, reason: String, token: String) async throws {
        let url = URL(string: "\(APIConfig.customAPI)/user/report")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body: [String: Any] = [
            "user_id": userId,
            "reason": reason
        ]
        request.httpBody = try JSONSerialization.data(withJSONObject: body)
        
        let (_, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            throw NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to report user"])
        }
    }
    
    func fetchBlockedUsers(token: String) async throws -> [Int] {
        let url = URL(string: "\(APIConfig.customAPI)/user/blocked_list")!
        var request = URLRequest(url: url)
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        let (data, _) = try await URLSession.shared.data(for: request)
        
        guard let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
              let blockedUsers = json["blocked_users"] as? [Int] else {
            return []
        }
        
        return blockedUsers
    }
    
    func fetchMutedUsers(token: String) async throws -> [Int] {
        let url = URL(string: "\(APIConfig.customAPI)/user/muted_list")!
        var request = URLRequest(url: url)
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        let (data, _) = try await URLSession.shared.data(for: request)
        
        guard let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
              let mutedUsers = json["muted_users"] as? [Int] else {
            return []
        }
        
        return mutedUsers
    }
    
    // MARK: - Groups
    
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
    
    // MARK: - Leaderboard
    
    func fetchLeaderboard(type: String, limit: Int = 15) async throws -> [LeaderboardEntry] {
        // TODO: Implement when backend endpoint is ready
        return []
    }
}
