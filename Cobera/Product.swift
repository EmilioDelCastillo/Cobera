//
//  Product.swift
//  Cobera
//
//  Created by Emilio Del Castillo on 01/04/2021.
//

import Foundation

class Product: NSObject, NSCoding {
    enum CapacityUnit: String, CaseIterable {
        case mililitre = "ml"
        case centilitre = "cl"
        case litre = "l"
        case gram = "g"
        case kilo = "kg"
    }
    
    var identifier: String
    
    var brand: String
    var name: String
    
    var capacity: Int
    var capacityUnit: CapacityUnit
    
    /**
     Retruns a dictionary with all the variables of the instance.
     */
    var dictionary: [String: Any] {
        return ["name": name,
                "brand": brand,
                "capacity": capacity,
                "capacityUnit": capacityUnit.rawValue]
    }
    
    func encode(with coder: NSCoder) {
        coder.encode(identifier, forKey: "identifier")
        coder.encode(brand, forKey: "brand")
        coder.encode(name, forKey: "name")
        coder.encode(capacity, forKey: "capacity")
        coder.encode(capacityUnit.rawValue, forKey: "capacityUnit")
    }
    
    required convenience init?(coder: NSCoder) {
        let identifier = coder.decodeObject(forKey: "identifier") as! String
        let brand = coder.decodeObject(forKey: "brand") as! String
        let name = coder.decodeObject(forKey: "name") as! String
        let capacity = coder.decodeInteger(forKey: "capacity")
        let capacityUnit = CapacityUnit(rawValue: coder.decodeObject(forKey: "capacityUnit") as! String)!
        
        self.init(identifier: identifier, brand: brand, name: name, capacity: capacity, capacityUnit: capacityUnit)
    }
    
    init(identifier: String, brand: String, name: String, capacity: Int, capacityUnit: CapacityUnit) {
        self.identifier = identifier
        self.brand = brand
        self.name = name
        self.capacity = capacity
        self.capacityUnit = capacityUnit
    }
    
    /**
     Returns a hopefully unique identifier for a product without barcode.
     - Parameters:
        - brand: The product brand
        - name: The product name
        - capacity: The product capacity
        - capacityUnit: The unit (e.g., ml)
     
    When a product is added manually, no barcode is provided. This function should help to identify it.
     */
    class func getUniqueIdentifier(brand: String, name: String, capacity: Int, capacityUnit: CapacityUnit) -> String {
        return brand + name + capacity.description + capacityUnit.rawValue
    }
}
