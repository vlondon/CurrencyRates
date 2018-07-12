import Foundation

protocol RatesProvider {
    func getExchangeRates(for code: BaseCode, didGetItems: @escaping (([RateItem], Error?) -> Void))
}

class NetworkLayer {
    
    private let apiUrl = "https://revolut.duckdns.org"
    
}

extension NetworkLayer: RatesProvider {
    
    func getExchangeRates(for code: BaseCode, didGetItems: @escaping (([RateItem], Error?) -> Void)) {
        let urlString = "\(apiUrl)/latest?base=\(code)"
        guard let url = URL(string: urlString) else { return }
        
        let baseItem = RateItem(code: code, rate: 1.0)
        
        URLSession.shared.dataTask(with: url) { (data, response, error) in
            if let error = error {
                print(error.localizedDescription)
                didGetItems([], error)
                return
            }
            guard let data = data else {
                didGetItems([], nil)
                return
            }
            
            do {
                let ratesData = try JSONDecoder().decode(RatesDTO.self, from: data)
                var items = ratesData.rates.map({ (code, rate) -> RateItem in
                    return RateItem(code: code, rate: rate)
                })
                items.append(baseItem)
                
                didGetItems(items, nil)
                
            } catch let jsonError {
                didGetItems([], jsonError)
            }
        }.resume()
    }
    
}
