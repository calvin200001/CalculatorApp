// In CalculatorService.swift

import Foundation
import CoreData

// --- Ensure CalculatorError and Calculator.Operation are defined correctly elsewhere ---
/*
 enum CalculatorError: Error { ... }
 struct Calculator { enum Operation: String { ... } }
 */

class CalculatorService {
    private var operands: [Double] = []
    private var operations: [Calculator.Operation] = []
    private var context: NSManagedObjectContext

    // --- Keep init, appendNumber, storeOperation as they were ---
    init(context: NSManagedObjectContext) {
        self.context = context
    }

    func appendNumber(_ number: Double) {
        print("Service: Appending number \(number)")
        // If operands already contains a result from a previous calculation,
        // and a new number is appended without an intervening operation,
        // clear the old result to start fresh. This handles "2 + 2 = 4" then pressing "9" -> should show "9", not "49".
        // This check assumes a calculation just happened if operands has 1 item and operations is empty.
        if operands.count == 1 && operations.isEmpty {
             print("Service: New number appended after result, clearing previous result.")
             operands.removeAll()
        }
        operands.append(number)
    }

    func storeOperation(_ operation: Calculator.Operation) {
        print("Service: Storing operation \(operation.string)")
        // Basic handling: if there's already an operation pending, calculate first (simple precedence)
        // A more robust implementation would handle precedence rules properly.
        if operands.count >= 2 && operations.count >= 1 {
            print("Service: Chained operation detected, calculating intermediate result.")
            do {
                // Temporarily perform calculation to update the first operand
                let intermediateResult = try calculateIntermediateResult()
                operands = [intermediateResult] // Keep only the result
                operations.removeAll() // Clear the old operation
                 print("Service: Intermediate result \(intermediateResult)")
            } catch {
                 print("Service: Error during intermediate calculation: \(error)")
                 // Handle error appropriately - maybe clear state or throw
                 clear() // Simple error handling: clear state
                 // Optionally rethrow or handle differently
                 return // Stop processing this operation if intermediate calc failed
            }
        }

        // If only one operand exists (either initial or result of previous calc), store the operation.
        operations.append(operation)
    }

    // Helper for intermediate calculations without saving/full reset
    private func calculateIntermediateResult() throws -> Double {
         guard operands.count >= 2, let operation = operations.first else {
              // This shouldn't be called unless conditions are met, but safeguard
              throw CalculatorError.invalidOperation // Or a more specific error
         }
         let operand1 = operands[0]
         let operand2 = operands[1]
         var result: Double = 0

         switch operation {
         case .add: result = operand1 + operand2
         case .subtract: result = operand1 - operand2
         case .multiply: result = operand1 * operand2
         case .divide:
             if operand2 == 0 { throw CalculatorError.divisionByZero }
             result = operand1 / operand2
         }
         return result
    }


    func calculate() throws -> Double {
        print("Service: Calculating with operands: \(operands), operations: \(operations)")

        guard operands.count >= 1 else { // Need at least one operand
             print("Service: Error - Insufficient operands (\(operands.count))")
            throw CalculatorError.insufficientOperands
        }

        // Handle case like "5 =" -> should result in 5
        if operands.count == 1 && operations.isEmpty {
            print("Service: Calculate called with single operand, returning it.")
            return operands[0]
        }

         // Handle case like "5 + =" -> should result in 10 (use first operand as second)
         var operand2 = operands.last ?? 0 // Default if something went wrong
         if operands.count == 1 && operations.count == 1 {
              operand2 = operands[0] // Reuse first operand
              operands.append(operand2) // Add it for calculation logic below
              print("Service: Reusing first operand (\(operand2)) for calculation.")
         }

        guard operands.count >= 2 else {
             print("Service: Error - Insufficient operands for operation (\(operands.count))")
            throw CalculatorError.insufficientOperands
        }

        guard !operations.isEmpty else {
            print("Service: Error - No operation stored for calculation")
            throw CalculatorError.invalidOperation
        }

        // Using the first stored operation and assuming enough operands exist now
        let operand1 = operands[0]
        // operand2 is already determined above
        let operation = operations[0]
        var result: Double = 0

        // Perform the calculation
        switch operation {
        case .add: result = operand1 + operand2
        case .subtract: result = operand1 - operand2
        case .multiply: result = operand1 * operand2
        case .divide:
            if operand2 == 0 {
                print("Service: Error - Division by zero")
                throw CalculatorError.divisionByZero
            }
            result = operand1 / operand2
        }
        print("Service: Calculation result = \(result)")

        // Save to history
        let historyEntry = CalculatorModel(context: context)
        historyEntry.operand1 = operand1
        historyEntry.operand2 = operand2 // Save the operand used
        historyEntry.operationType = operation.string
        historyEntry.result = result
        historyEntry.date = Date()
        do {
            try context.save()
            print("Service: Saved calculation to history.")
        } catch {
            print("Service: Failed to save calculation to history: \(error)")
        }

        // --- MODIFICATION FOR CHAINING ---
        // Instead of clear(), keep result for next operation
        operands = [result]
        operations.removeAll()
        print("Service: State reset for chaining. Operands: \(operands)")
        // --- END MODIFICATION ---

        return result
    }

    func clear() {
        print("Service: Clearing state.")
        operands.removeAll()
        operations.removeAll()
    }

    // --- Keep applyPercent, fetchHistory, importLegacyHistory as they were ---
    func applyPercent(currentValue: Double) -> Double {
        print("Service: applyPercent called with \(currentValue)")
        let result = currentValue / 100.0
        print("Service: applyPercent result \(result)")
        return result
    }

    func fetchHistory() -> [CalculatorModel] {
        let fetchRequest: NSFetchRequest<CalculatorModel> = CalculatorModel.fetchRequest()
        let sortDescriptor = NSSortDescriptor(key: "date", ascending: false)
        fetchRequest.sortDescriptors = [sortDescriptor]
        do {
            let history = try context.fetch(fetchRequest)
            print("Service: Fetched \(history.count) history items.")
            return history
        } catch {
            print("Service: Failed to fetch history: \(error)")
            return []
        }
    }

    func importLegacyHistory(with historyManager: HistoryManager) {
        print("Service: Attempting to import legacy history...")
        // Assuming HistoryManager is defined elsewhere
        historyManager.importFromLegacy(to: context)
        print("Service: Legacy history import attempt finished.")
    }
}