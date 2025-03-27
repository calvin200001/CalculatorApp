import Foundation
import CoreData

class HistoryManager {
    private let historyKey = "calculator_history"
    
    // This class is now a wrapper around CoreData functionality
    // for backwards compatibility
    
    func importFromLegacy(to context: NSManagedObjectContext) {
        // Load legacy data from UserDefaults if exists
        guard let data = UserDefaults.standard.data(forKey: historyKey) else {
            return
        }
        
        do {
            let decoder = JSONDecoder()
            if let sessions = try? decoder.decode([HistorySession].self, from: data) {
                // Convert legacy sessions to CoreData
                for session in sessions {
                    if let operation = operationFromExpression(session.expression) {
                        let historyEntry = CalculatorModel(context: context)
                        historyEntry.operationType = operation.type
                        historyEntry.operand1 = operation.operand1
                        historyEntry.operand2 = operation.operand2
                        historyEntry.result = Double(session.result) ?? 0
                        historyEntry.date = session.date
                    }
                }
                
                // Save the context after importing all sessions
                try context.save()
                
                // Clear legacy data
                UserDefaults.standard.removeObject(forKey: historyKey)
            }
        } catch {
            print("Error importing legacy history: \(error)")
        }
    }
    
    private func operationFromExpression(_ expression: String) -> (type: String, operand1: Double, operand2: Double)? {
        // Simple parser for expressions like "2 + 3"
        let components = expression.components(separatedBy: " ")
        if components.count >= 3 {
            if let operand1 = Double(components[0]), let operand2 = Double(components[2]) {
                let operationType = components[1]
                return (operationType, operand1, operand2)
            }
        }
        return nil
    }
}
