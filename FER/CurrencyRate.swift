//
//  CurrencyRate.swift
//  FER
//
//  Created by Dmitry Reshetnik on 09.11.2020.
//

import Foundation

struct Rate: Codable {
    var ticker: String
    var value: Double
}

struct CurrencyRate: Codable {
    var rates: [String: Double]
    var base: String
    var date: String
}
