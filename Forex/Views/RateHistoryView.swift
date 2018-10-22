//
//  RateHistoryView.swift
//  Forex
//
//  Created by Andrew R Madsen on 10/21/18.
//  Copyright © 2018 Lambda School. All rights reserved.
//

import UIKit

class RateHistoryView: UIView {
    
    override func draw(_ rect: CGRect) {
        let path = UIBezierPath()
        if let first = exchangeRates.first {
            path.move(to: point(for: first))
        }
        for exchangeRate in exchangeRates.dropFirst() {
            path.addLine(to: point(for: exchangeRate))
        }
        
        UIColor.cyan.set()
        path.stroke()
    }
    
    private func point(for exchangeRate: ExchangeRate) -> CGPoint {
        
        let calendar = Calendar.current
        
        guard let minDate = exchangeRates.first?.date,
            let maxDate = exchangeRates.last?.date,
            let minRate = exchangeRates.min(by: { $0.rate < $1.rate })?.rate,
            let maxRate = exchangeRates.max(by: { $0.rate < $1.rate })?.rate,
            let numDays = calendar.dateComponents([.day], from: minDate, to: maxDate).day,
            maxDate != minDate,
            minRate != maxRate else {
                return .zero
        }
        
        let rateRange = maxRate - minRate
        let rateStep = bounds.height / CGFloat(rateRange)
        let dayStep = bounds.width / CGFloat(numDays)
        
        let yPosition = bounds.maxY - rateStep * CGFloat(exchangeRate.rate - minRate)
        guard let daysSinceBeginning = calendar.dateComponents([.day], from: minDate, to: exchangeRate.date).day else { return .zero }
        let xPosition = bounds.minX + CGFloat(daysSinceBeginning) * dayStep
        return CGPoint(x: xPosition, y: yPosition)
    }
    
    var exchangeRates = [ExchangeRate]() {
        didSet {
            self.exchangeRates = exchangeRates.sorted { $0.date < $1.date }
            setNeedsDisplay(bounds)
        }
    }
}
