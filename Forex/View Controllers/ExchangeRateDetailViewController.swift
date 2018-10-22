//
//  ViewController.swift
//  Forex
//
//  Created by Andrew R Madsen on 10/21/18.
//  Copyright © 2018 Lambda School. All rights reserved.
//

import UIKit

class ExchangeRateDetailViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let symbol = symbol, rates.isEmpty {
            self.fetchRates(for: symbol)
        }
    }
    
    // MARK: - Private
    
    private func fetchRates(for symbol: String) {
        
        let calendar = Calendar.current
        let now = calendar.startOfDay(for: Date())
        var components = DateComponents()
        components.calendar = calendar
        components.year = -1
        let aYearAgo = calendar.date(byAdding: components, to: now)!
        
        fetcher.fetchCurrentExchangeRate(for: symbol) { (rate, error) in
            if let error = error {
                NSLog("Error fetching exchange rates: \(error)")
                return
            }
            if let rate = rate {
                DispatchQueue.main.async {
                    self.updateViews(with: rate)
                }
            }
        }
        
        fetcher.fetchExchangeRates(startDate: aYearAgo, symbols: ["JPY"]) { (rates, error) in
            if let error = error {
                NSLog("Error fetching exchange rates: \(error)")
                return
            }
            self.rates = rates ?? []
        }
    }
    
    private func updateViews(with rate: ExchangeRate) {
        guard isViewLoaded else { return }
        
        self.currencyLabel.text = rate.symbol
        self.currentRateLabel.text = (currencyFormatter.string(from: rate.rate as NSNumber) ?? "") + " \(rate.symbol) = 1 \(rate.base)"
        self.rateHistoryView.exchangeRates = rates
    }
    
    // MARK: - Properties
    
    var symbol: String? {
        didSet {
            if let symbol = symbol {
                fetchRates(for: symbol)
            }
        }
    }
    
    private var rates = [ExchangeRate]() {
        didSet {
            DispatchQueue.main.async {
                self.rateHistoryView?.exchangeRates = self.rates
            }
        }
    }
    private let fetcher = ExchangeRateFetcher()
    
    private var currencyFormatter: NumberFormatter = {
        let result = NumberFormatter()
        result.numberStyle = .decimal
        result.maximumFractionDigits = 2
        result.minimumIntegerDigits = 1
        return result
    }()
    
    @IBOutlet var currencyLabel: UILabel!
    @IBOutlet var currentRateLabel: UILabel!
    @IBOutlet var rateHistoryView: RateHistoryView!
}

