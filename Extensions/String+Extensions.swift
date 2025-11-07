import Foundation
internal import UIKit

extension String {
    /// Strips HTML tags from the string
    func stripHTML() -> String {
        return self.replacingOccurrences(of: "<[^>]+>", with: "", options: .regularExpression, range: nil)
    }
    
    /// Decodes HTML entities like &#8217; (apostrophe), &amp; (ampersand), etc.
    func decodingHTMLEntities() -> String {
        guard let data = self.data(using: .utf8) else {
            return self
        }
        
        let options: [NSAttributedString.DocumentReadingOptionKey: Any] = [
            .documentType: NSAttributedString.DocumentType.html,
            .characterEncoding: String.Encoding.utf8.rawValue
        ]
        
        guard let attributedString = try? NSAttributedString(data: data, options: options, documentAttributes: nil) else {
            return self
        }
        
        return attributedString.string
    }
    
    /// Convenience method that both strips HTML and decodes entities
    func cleanHTML() -> String {
        return self.stripHTML().decodingHTMLEntities()
    }
}
