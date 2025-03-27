import Foundation

/// Represents a single calculation session in the history
/// - Note: This type conforms to `Codable` for easy serialization and `Identifiable` for use in SwiftUI lists
struct HistorySession: Codable, Identifiable {
    let id = UUID() // Unique identifier for each session
    let expression: String
    let result: String
    let date: Date
    let formattedDate: String // Adding formatted date for easier display
    
    init(expression: String, result: String) {
        self.expression = expression
        self.result = result
        self.date = Date()
        self.formattedDate = DateFormatter.localizedString(from: date, dateStyle: .short, timeStyle: .short)
    }
}

extension HistorySession {
    /// Provides a formatted string for display in the history list
    var displayText: String {
        return "\(expression) = \(result)"
    }
}