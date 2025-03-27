import Foundation
import CoreData

class Calculator {
    enum Operation {
        case add, subtract, multiply, divide
        
        var string: String {
            switch self {
            case .add: return "+"
            case .subtract: return "-"
            case .multiply: return "×"
            case .divide: return "÷"
            }
        }
    }
    
    private let service: CalculatorService
    
    init(service: CalculatorService) {
        self.service = service
    }
    
    func appendNumber(_ number: Double) throws {
        service.appendNumber(number)
    }
    
    func storeOperation(_ operation: Operation) throws {
        service.storeOperation(operation)
    }
    
    func calculate() throws -> Double {
        try service.calculate()
    }
    
    func clear() {
        service.clear()
    }
}

enum CalculatorError: Error {
    case invalidOperation
    case divisionByZero
    case insufficientOperands
    case unknownError
}
