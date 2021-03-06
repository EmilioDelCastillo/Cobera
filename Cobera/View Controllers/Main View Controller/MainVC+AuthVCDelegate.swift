//
//  MainVC+AuthVCDelegate.swift
//  Cobera
//
//  Created by Emilio Del Castillo on 08/04/2021.
//

import UIKit

extension MainVC: AuthenticationViewControllerDelegate {
    func didLogin() {
        let spinner = createActivityIndicator()
        
        AppData.shared.readAllItems { result in
            switch result {
            case .success(let items):
                self.handleItems(items: items)
                
            case .failure(let error):
                self.handleFailure(error)
            }
            spinner.stopAnimating()
        }
    }
    
    /**
     Handle the possible `[UserItem]` payload that arrives when a user logs in.
     - Parameter items: An array of `UserItem`
     
     It presents an alert with the possible actions.
     */
    private func handleItems(items: [UserItem]) {
        if items.count > 0 {
            let message = """
                Your account has items on the cloud.
                What do you want to do?
                """
            let alert = UIAlertController(title: "Items found", message: message, preferredStyle: .alert)
            
            // Different message if local items exist.
            let actionTitle = (AppData.shared.userItems.count > 0) ? "Merge with local items" : "Download from cloud"
            alert.addAction(UIAlertAction(title: actionTitle, style: .default, handler: { _ in
                AppData.shared.merge(items: items)
                self.reloadTableViewData()
            }))
            
            // Only show this option if there are local items to discard.
            if AppData.shared.userItems.count > 0 {
                alert.addAction(UIAlertAction(title: "Discard local items", style: .destructive, handler: { _ in
                    
                    let alert = UIAlertController(title: "Please confirm", message: "This action cant be undone", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { _ in
                        self.handleItems(items: items)
                    }))
                    alert.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: { _ in
                        AppData.shared.userItems = items
                        AppData.shared.updateStoredProducts()
                        self.reloadTableViewData()
                    }))
                    self.present(alert, animated: true)
                    
                }))
            }
            
            alert.addAction(UIAlertAction(title: "Discard cloud items", style: .destructive, handler: { _ in
                
                let alert = UIAlertController(title: "Please confirm", message: "This action cant be undone", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { _ in
                    self.handleItems(items: items)
                }))
                alert.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: { _ in
                    AppData.shared.deleteEverythingFromDatabase()
                }))
                self.present(alert, animated: true)
                
            }))
            
            present(alert, animated: true)
        }
    }
    
    /**
     Handle the possible failures that happen while retrieving the user's items from the cloud.
     - Parameter error: The error given by the network call
     
     It presents an alert informing the user of what happened, and handles the case of multiple calls.
     */
    private func handleFailure(_ error: AppData.DatabaseError) {
        var title: String?
        var message: String?
        switch error {
        case .noData:
            title = "Some data was not found"
            message = nil
        case .wrongData:
            title = "Corrupted data"
            message = "Some data was corrupted."
        }
        
        if let presented = presentedViewController as? UIAlertController {
            // This means an error has already occured.
            presented.title = "Errors occurred."
            presented.message! += "\n\(message!)"
            
        } else {
            displaySimpleAlert(title: title, message: message)
        }
    }
}
