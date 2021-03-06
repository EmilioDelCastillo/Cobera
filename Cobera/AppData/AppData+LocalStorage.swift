//
//  AppData+LocalStorage.swift
//  Cobera
//
//  Created by Emilio Del Castillo on 03/04/2021.
//

import Foundation

extension AppData {
    
    func addProduct(_ newProduct: Product, _ quantity: Int, type: UserItem.TypeOfAddition) {
        guard userItems != nil else { return }
        print("Adding product...")
        
        // Prevent duplicates:
        if let duplicate = userItems.firstIndex(where: { product in
            product.product.identifier == newProduct.identifier
        }) {
            userItems[duplicate].quantity += quantity
        } else {
            let item = UserItem(product: newProduct, quantity: quantity, type)
            userItems.append(item)
            writeItemsToDatabase(items: [item])
        }
        
        updateStoredProducts()
    }
    
    func updateStoredProducts() {
        guard userItems != nil else { return }
        let dataPath = docsURL.appendingPathComponent(documentName)
        
        do {
            let archiver = try NSKeyedArchiver.archivedData(withRootObject: userItems!, requiringSecureCoding: false)
            try archiver.write(to: dataPath)
            print("Successfully stored products")
        } catch {
            print(error)
        }
    }
    
    /**
     Updates the quantity of the item at the given row
     - Parameter newQuantity: The updated quantity
     - Parameter row: The index of the item to update
     */
    func updateQuantity(_ newQuantity: Int, forRow row: Int){
        assert(userItems != nil, "userItems has not been initialized.")
        userItems[row].quantity = newQuantity
        writeItemsToDatabase(items: [userItems[row]])
        updateStoredProducts()
    }
    
    func getStoredProducts() {
        let dataPath = docsURL.appendingPathComponent(documentName)
        if let data = try? Data(contentsOf: dataPath) {
            do {
                let foundProducts = try NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(data) as? [UserItem]
                userItems = foundProducts
                
            } catch {
                print(error)
                userItems = []
            }
        } else {
            userItems = []
        }
    }
    
    func loadUserPreferences() {
        if let rawValue = defaults.object(forKey: "sortingOrder") as? String {
            currentSortingOrder = SortingOrder(rawValue: rawValue)!
        } else {
            currentSortingOrder = .asc
        }
        if let rawValue = defaults.object(forKey: "sortingParameter") as? String {
            currentSortingParameter = SortingParameter(rawValue: rawValue)!
        } else {
            currentSortingParameter = .quantity
        }
        
    }
}
