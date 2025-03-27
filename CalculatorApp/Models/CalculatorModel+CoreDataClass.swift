import Foundation
import CoreData

@objc(CalculatorModel)
public class CalculatorModel: NSManagedObject {
    @NSManaged public var operand1: Double
    @NSManaged public var operand2: Double
    @NSManaged public var operationType: String?
    @NSManaged public var result: Double
    @NSManaged public var date: Date
    
    @nonobjc public class func fetchRequest() -> NSFetchRequest<CalculatorModel> {
        return NSFetchRequest<CalculatorModel>(entityName: "CalculatorModel")
    }
}