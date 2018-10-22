//
//  SymbolsTableViewController.swift
//  Forex
//
//  Created by Andrew R Madsen on 10/22/18.
//  Copyright © 2018 Lambda School. All rights reserved.
//

import UIKit

class SymbolsTableViewController: UITableViewController {
    
    // MARK: - Table view data source
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return symbols.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SymbolCell", for: indexPath)
        
        cell.textLabel?.text = symbols[indexPath.row]
        
        return cell
    }
    
    
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ShowDetail" {
            let detailVC = segue.destination as! ExchangeRateDetailViewController
            let indexPath = tableView.indexPathForSelectedRow!
            detailVC.symbol = symbols[indexPath.row]
        }
    }
    
    private let symbols = ["BGN",
                           "CAD",
                           "BRL",
                           "HUF",
                           "DKK",
                           "JPY",
                           "ILS",
                           "TRY",
                           "RON",
                           "GBP",
                           "PHP",
                           "HRK",
                           "NOK",
                           "USD",
                           "MXN",
                           "AUD",
                           "IDR",
                           "KRW",
                           "HKD",
                           "ZAR",
                           "ISK",
                           "CZK",
                           "THB",
                           "MYR",
                           "NZD",
                           "PLN",
                           "SEK",
                           "RUB",
                           "CNY",
                           "SGD",
                           "CHF",
                           "INR"].sorted()
}
