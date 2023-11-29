//
//  CoinManager.swift
//  ByteCoin
//
//  Created by Angela Yu on 11/09/2019.
//  Copyright © 2019 The App Brewery. All rights reserved.
//

import Foundation

protocol CoinManagerDelegate {
    func didUpdateBTCPrice(coinManager: CoinManager, rate: CoinModel)
}

struct CoinManager {
    
    let baseURL = "https://rest.coinapi.io/v1/exchangerate/BTC/"
    let apiKey = "tacotuesday"
    var delegate: CoinManagerDelegate?
    
    let currencyArray = ["AUD", "BRL","CAD","CNY","EUR","GBP","HKD","IDR","ILS","INR","JPY","MXN","NOK","NZD","PLN","RON","RUB","SEK","SGD","USD","ZAR"]

    func getCoinPrice(for currency: String) {
        let urlString = baseURL + currency + "?apikey=" + apiKey
        performRequest(with: urlString)
    }
    
    func performRequest(with URLString: String) {
        if let URL = URL(string: URLString) {
            let session = URLSession(configuration: .default)
            let task = session.dataTask(with: URL) { (data, response, error) in
                if (error != nil) {
                    print("Error with BTC price: ", error!)
                    return
                }
                if let safeData = data {
                    //print(String(decoding: safeData, as: UTF8.self))
                    if let rate = self.parseCoinAPIJSON(safeData) {
                        self.delegate?.didUpdateBTCPrice(coinManager: self, rate: rate)
                    }
                }
            }
            task.resume()
        }
    }
    
    func parseCoinAPIJSON(_ btcData: Data) -> CoinModel? {
        let decoder = JSONDecoder()
        do {
            let decodedData = try decoder.decode(CoinData.self, from: btcData)
            let rate = decodedData.rate
            let currency = decodedData.asset_id_quote
            let btcData = CoinModel(rate: rate, currency: currency)
            return btcData
        }
        catch {
            print("Error with parsing temp JSON: ", error)
            return nil
        }
    }
    
}
