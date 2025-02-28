import Foundation

class Calculator {
    enum Operation {
        case add, subtract, multiply, divide
    }
    
    private var operands: [Double] = []
    private var operations: [Operation] = []
    
    func appendNumber(_ number: Double) {
        operands.append(number)
    }
    
    func storeOperation(_ operation: Operation) {
        operations.append(operation)
    }
    
    func calculate() -> Double? {
        guard operands.count > operations.count else { return nil }
        
        var result = operands[0]
        for i in 0..<operations.count {
            let nextOperand = operands[i + 1]
            
            switch operations[i] {
            case .add:
                result += nextOperand
            case .subtract:
                result -= nextOperand
            case .multiply:
                result *= nextOperand
            case .divide:
                guard nextOperand != 0 else { return nil }
                result /= nextOperand
            }
        }
        
        operands = [result]
        operations = []
        
        return result
    }
    
    func clear() {
        operands = []
        operations = []
    }
}