//
//  ExchangeRateFetcher.swift
//  Forex
//
//  Created by Andrew R Madsen on 10/21/18.
//  Copyright © 2018 Lambda School. All rights reserved.
//

import Foundation

public class ExchangeRateFetcher {
    
    public enum FetcherError: Int, Error {
        case unknownError
        case noData
        case invalidURL
    }
    
    public func fetchCurrentExchangeRate(for symbol: String,
                                         base: String = "USD",
                                         completion: @escaping (ExchangeRate?, Error?) -> Void) {
        let latestURL = baseURL.appendingPathComponent("latest")
        var urlComponents = URLComponents(url: latestURL, resolvingAgainstBaseURL: true)!
        var queryItems = [URLQueryItem]()
        queryItems.append(URLQueryItem(name: "symbols", value: symbol))
        queryItems.append(URLQueryItem(name: "base", value: base))
        urlComponents.queryItems = queryItems
        let url = urlComponents.url!
        
        URLSession.shared.dataTask(with: url) { (data, _, error) in
            if let error = error {
                completion(nil, error)
                return
            }
            
            guard let data = data else {
                completion(nil, FetcherError.noData)
                return
            }
            
            do {
                guard let jsonDict = try JSONSerialization.jsonObject(with: data, options: []) as? [String : Any],
                    let dateString = jsonDict["date"] as? String,
                    let date = self.dateFormatter.date(from: dateString),
                    let base = jsonDict["base"] as? String,
                    let rateDict = jsonDict["rates"] as? [String : Double],
                    let (symbol, rateValue) = rateDict.first else {
                        completion(nil, FetcherError.noData)
                        return
                }
                let exchangeRate = ExchangeRate(symbol: symbol, date: date, rate: rateValue, base: base)
                completion(exchangeRate, nil)
            } catch {
                completion(nil, error)
                return
            }
            }.resume()
        
    }
    
    public func fetchExchangeRates(startDate: Date,
                                   endDate: Date = Date(),
                                   symbols: [String]? = nil,
                                   base: String = "USD",
                                   completion: @escaping ([ExchangeRate]?, Error?) -> Void) {
        let historyURL = baseURL.appendingPathComponent("history")
        var urlComponents = URLComponents(url: historyURL, resolvingAgainstBaseURL: true)!
        var queryItems = [URLQueryItem]()
        queryItems.append(URLQueryItem(name: "start_at", value: dateFormatter.string(from: startDate)))
        queryItems.append(URLQueryItem(name: "end_at", value: dateFormatter.string(from: endDate)))
        queryItems.append(URLQueryItem(name: "base", value: base))
        if let symbols = symbols {
            let symbolsString = symbols.joined(separator: ",")
            queryItems.append(URLQueryItem(name: "symbols", value: symbolsString))
        }
        urlComponents.queryItems = queryItems
        let url = urlComponents.url!
        
        URLSession.shared.dataTask(with: url) { (data, _, error) in
            if let error = error {
                completion(nil, error)
                return
            }
            
            guard let data = data else {
                completion(nil, FetcherError.noData)
                return
            }
            
            do {
                guard let jsonDict = try JSONSerialization.jsonObject(with: data, options: []) as? [String : Any],
                    let base = jsonDict["base"] as? String,
                    let rates = jsonDict["rates"] as? [String : [String : Double]] else {
                        completion(nil, FetcherError.noData)
                        return
                }
                var exchangeRates = [ExchangeRate]()
                for (dateString, rateDict) in rates {
                    if let date = self.dateFormatter.date(from: dateString) {
                        for (symbol, rateValue) in rateDict {
                            let exchangeRate = ExchangeRate(symbol: symbol, date: date, rate: rateValue, base: base)
                            exchangeRates.append(exchangeRate)
                        }
                    }
                }
                completion(exchangeRates, nil)
            } catch {
                completion(nil, error)
                return
            }
            }.resume()
    }
    
    private let baseURL = URL(string: "https://api.exchangeratesapi.io/")!
    private let dateFormatter: DateFormatter = {
        let result = DateFormatter()
        result.timeStyle = .none
        result.dateFormat = "yyyy-MM-dd"
        return result
    }()
}
