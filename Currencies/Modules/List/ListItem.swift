import UIKit

typealias BaseCode = String

struct ListItem {
    let image: UIImage?
    let title: String
    let description: String
    let value: Double
    
    func getFormattedValue() -> String {
        return String(format: "%.2f", value)
    }
    
    init(with rateItem: RateItem, amount: Double) {
        self.image = UIImage(named: rateItem.code.lowercased())
        self.title = rateItem.code
        self.description = Locale.current.localizedString(forCurrencyCode: rateItem.code) ?? ""
        self.value = amount * rateItem.rate
    }
}
