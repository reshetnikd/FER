//
//  DataManager.swift
//  FER
//
//  Created by Dmitry Reshetnik on 10.11.2020.
//

import Foundation

enum ExchangeRatesAPI {
    static let BaseURL = URL(string: "https://api.exchangeratesapi.io/")!
}

enum DataManagerError: Error {
    case Unknown
    case FailedRequest
    case InvalidResponse
}

final class DataManager {
    typealias CurrencyDataCompletion = (CurrencyRate?, DataManagerError?) -> ()
    private let baseURL: URL
    
    init(baseURL: URL) {
        self.baseURL = baseURL
    }
    
    func getCurrencyRatesFor(base: String, date: Date, completion: @escaping CurrencyDataCompletion) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "YYYY-MM-dd"
        
        let url = baseURL.appendingPathComponent((dateFormatter.string(from: date)))
        let query = URLQueryItem(name: "base", value: base)
        var componetns = URLComponents(string: url.absoluteString)!
        componetns.queryItems = [query]
        
        URLSession.shared.dataTask(with: componetns.url!, completionHandler: { (data, response, error) in
            self.didFetchCurrencyData(data: data, response: response, error: error, completion: completion)
        }).resume()
    }
    
    private func didFetchCurrencyData(data: Data?, response: URLResponse?, error: Error?, completion: CurrencyDataCompletion) {
        if let _ = error {
            completion(nil, DataManagerError.FailedRequest)
        } else if let data = data, let response = response as? HTTPURLResponse {
            if response.statusCode == 200 {
                processCurrencyData(data: data, completion: completion)
            } else {
                completion(nil, DataManagerError.FailedRequest)
            }
        } else {
            completion(nil, DataManagerError.Unknown)
        }
    }
    
    private func processCurrencyData(data: Data, completion: CurrencyDataCompletion) {
        if let decodedResponse = try? JSONDecoder().decode(CurrencyRate.self, from: data) {
            completion(CurrencyRate.init(rates: decodedResponse.rates, base: decodedResponse.base, date: decodedResponse.date), nil)
        } else {
            completion(nil, DataManagerError.InvalidResponse)
        }
    }
}
