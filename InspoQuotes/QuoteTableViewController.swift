//
//  QuoteTableViewController.swift
//  InspoQuotes
//
//  Created by Angela Yu on 18/08/2018.
//  Copyright © 2018 London App Brewery. All rights reserved.
//

import UIKit
import StoreKit

class QuoteTableViewController: UITableViewController, SKPaymentTransactionObserver {
    
    // same ID you put on the App Purchase in the Apple Store Connect
    let productID = "com.londonappbreavery.InspoQuotes.PremiumQuotes"
    
    var quotesToShow = [
        "Our greatest glory is not in never falling, but in rising every time we fall. — Confucius",
        "All our dreams can come true, if we have the courage to pursue them. – Walt Disney",
        "It does not matter how slowly you go as long as you do not stop. – Confucius",
        "Everything you’ve ever wanted is on the other side of fear. — George Addair",
        "Success is not final, failure is not fatal: it is the courage to continue that counts. – Winston Churchill",
        "Hardships often prepare ordinary people for an extraordinary destiny. – C.S. Lewis"
    ]
    
    let premiumQuotes = [
        "Believe in yourself. You are braver than you think, more talented than you know, and capable of more than you imagine. ― Roy T. Bennett",
        "I learned that courage was not the absence of fear, but the triumph over it. The brave man is not he who does not feel afraid, but he who conquers that fear. – Nelson Mandela",
        "There is only one thing that makes a dream impossible to achieve: the fear of failure. ― Paulo Coelho",
        "It’s not whether you get knocked down. It’s whether you get up. – Vince Lombardi",
        "Your true success in life begins only when you make the commitment to become excellent at what you do. — Brian Tracy",
        "Believe in yourself, take on your challenges, dig deep within yourself to conquer fears. Never let anyone bring you down. You got to keep going. – Chantal Sutherland"
    ]

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // we declare ourself as the observer of the SKPaymentTransactionObserver class
        SKPaymentQueue.default().add(self)
        
        // if purchase was done and the app was closed at the next open I check that and in case the purchase
        // was done, I append the premium quotes to the quotes to show
        if isPurchased() {
            showPremiumQuotes()
        }
    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if isPurchased() {
            return quotesToShow.count
        } else {
            // the quotes plus the buy button
            return quotesToShow.count + 1
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "QuoteCell", for: indexPath)
        
        // regular behaviour: the cells are populated with data from the quotes array
        if indexPath.row < quotesToShow.count {
            cell.textLabel?.text = quotesToShow[indexPath.row]
            // there is no limit for the max number of linex a text in a cell occupies
            cell.textLabel?.numberOfLines = 0
            cell.textLabel?.textColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
            cell.accessoryType = .none
        } else {
            // we hit the last cell (the extra one)
            cell.textLabel?.text = "Get more quotes!"
            cell.textLabel?.textColor = #colorLiteral(red: 0.3411764801, green: 0.6235294342, blue: 0.1686274558, alpha: 1)
            cell.accessoryType = .disclosureIndicator // indicate to the user that tapping this cell triggers an action
        }
        
        return cell
    }
    
    // MARK: - Table View delegate methods
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // if the buy button gets pressed
        if indexPath.row == quotesToShow.count {
            buyPremiumQuotes()
        }
        
        // rows deselect automatically
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    // MARK: - In app purchases methods
    
    func buyPremiumQuotes() {
        // check if the user can make in app purchases (parental control)
        if SKPaymentQueue.canMakePayments() {
            // we make a request to make a new in app purchase
            let paymentRequest = SKMutablePayment()
            // the product that we want is the one with product ID specified above
            paymentRequest.productIdentifier = self.productID
            // add the payment request to the queue in the app store
            SKPaymentQueue.default().add(paymentRequest)
        } else {
            // the function returns false: the user cannot make payments
            print("User can't make payments")
        }
    }
    
    // this method informs us when the transaction gets updated in the payment queue
    // and gets called every single time there is a modification in the transaction queue
    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        // loop for all the transactions in the queue
        // (because we MIGHT have multiple transactions at the same time)
        for transaction in transactions {
            if transaction.transactionState == .purchased {
                // user payment successfull
                
                // show the rest of the quotes
                showPremiumQuotes()
                
                // save to UserDefaults the fact that the user bought the premium quotes
                UserDefaults.standard.set(true, forKey: productID)
                
                // terminate the current transaction
                SKPaymentQueue.default().finishTransaction(transaction)
            } else if transaction.transactionState == .failed {
                
                // if there was an error
                if let error = transaction.error {
                    // display it on the console for debugging
                    let errorDescription = error.localizedDescription
                    print("Transaction failed due to error: \(errorDescription)")
                }
                
                // terminate the current transaction
                SKPaymentQueue.default().finishTransaction(transaction)
                
            } else if transaction.transactionState == .restored {
                // show the rest of the quotes
                showPremiumQuotes()
                
                // save to UserDefaults the fact that the user bought the premium quotes
                UserDefaults.standard.set(true, forKey: productID)
                
                // remove the restore button
                navigationItem.setRightBarButton(nil, animated: true)
                
                // terminate the current transaction
                SKPaymentQueue.default().finishTransaction(transaction)
            }
        }
    }
    
    func showPremiumQuotes() {
        // append the premium quotes in the first array of quotes to show
        quotesToShow.append(contentsOf: premiumQuotes)
        // update the table view
        tableView.reloadData()
    }
    
    
    func isPurchased() -> Bool {
        let purchaseStatus = UserDefaults.standard.bool(forKey: productID)
        
        if purchaseStatus {
            // Previously purchased
            return true
        } else {
            // Never purchases
            return false
        }
    }
    
    
    @IBAction func restorePressed(_ sender: UIBarButtonItem) {
        // restore the payment checking in Apple database and triggers the observer function
        SKPaymentQueue.default().restoreCompletedTransactions()
    }


}
