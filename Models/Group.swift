import Foundation

struct Group: Codable, Identifiable, Hashable {
    let id: Int
    let name: String
    let description: String?
    let status: String
    
    // Manual Hashable implementation
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    // Manual Equatable implementation
    static func == (lhs: Group, rhs: Group) -> Bool {
        lhs.id == rhs.id
    }
}
