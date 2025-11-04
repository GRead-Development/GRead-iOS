import Foundation

class APIService {
    static let shared = APIService()
    
    private init() {}
    
    // --- MODIFIED FUNCTION ---
    func fetchBooks(page: Int) async throws -> [Book] {
        // We add the 'page' parameter and set 'per_page' to 20
        let url = URL(string: "\(APIConfig.wpAPI)/book?per_page=20&page=\(page)")!
        
        let (data, _) = try await URLSession.shared.data(from: url)
        
        // This line may fail if the API returns an empty array on the last page.
        // We will handle that in the ViewModel.
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
        
 
        guard let httpResponse = response as?
 HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            throw NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to add book"])
        }
    }
    
    func fetchUserBooks(token: String) async throws -> [UserBook] {
        let url = URL(string: "\(APIConfig.customAPI)/library")!
        var request = URLRequest(url: url)
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        let (data, _) = try await URLSession.shared.data(for: request)
        
        // Parse response - adjust based on your actual API response
        guard let json = try JSONSerialization.jsonObject(with: data) as?
 [[String: Any]] else {
            return []
        }
        
        return json.compactMap { item in
            guard let bookId = item["book_id"] as?
 Int,
                  let currentPage = item["current_page"] as?
 Int,
                  let status = item["status"] as?
 String,
                  let bookData = item["book"] as?
 [String: Any],
                  let title = bookData["title"] as?
 String else {
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
        request.httpBody =
 try JSONEncoder().encode(body)
        
        let (_, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as?
 HTTPURLResponse,
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
    
    // MARK: - Added Functions
    
    /**
     * FIX: Added missing function to fetch the activity feed.
     */
    func fetchActivityFeed(page: Int, token: String) async throws -> [ActivityItem] {
        var components = URLComponents(string: "\(APIConfig.customAPI)/activity")!
        components.queryItems = [
            URLQueryItem(name: "page", value: "\(page)"),
            URLQueryItem(name: "per_page", value: "20")
        ]
        
        guard let url = components.url else {
            throw NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid URL for activity feed"])
        }
        
        var request = URLRequest(url: url)
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        let (data, _) = try await URLSession.shared.data(for: request)
        
        let decoder = JSONDecoder()
        let activities = try decoder.decode([ActivityItem].self, from: data)
        
        return activities
    }
    
    /**
     * NEW: Added function to post a new activity update.
     */
    func postActivityUpdate(content: String, token: String) async throws {
        let url = URL(string: "\(APIConfig.customAPI)/activity/post")!
        
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
    
    /**
     * FIX: Added missing function to fetch groups.
     */
    func fetchGroups(token: String) async throws -> [Group] {
        let url = URL(string: "\(APIConfig.customAPI)/groups")!
        
        var request = URLRequest(url: url)
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
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
        // This would connect to your WordPress leaderboard endpoints
        // For now, returning empty array - implement based on your API
        // NOTE: You will need to build the API endpoint for this in rest.php
        return []
    }
}
