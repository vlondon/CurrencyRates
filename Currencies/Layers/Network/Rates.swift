import Foundation

typealias Rates = [String: Double]

struct RatesDTO: Codable {
    let base: String
    let date: String
    let rates: Rates
}

struct RateItem {
    let code: BaseCode
    let rate: Double
}

extension RateItem: Equatable {
    
    static func == (lhs: RateItem, rhs: RateItem) -> Bool {
        return lhs.code == rhs.code && lhs.rate == rhs.rate
    }
    
}
