import Foundation

class ListCoordinator {
    
    weak var dataHandler: ListDataHandler?
    
    private let ratesProvider: RatesProvider
    private let baseItemCode: String
    private var amountDefault: Double = 100
    
    private var items = [RateItem]()
    private var leadCode: BaseCode?
    
    init(ratesProvider: RatesProvider, baseItemCode: String) {
        self.ratesProvider = ratesProvider
        self.baseItemCode = baseItemCode
    }
    
    deinit {
        print("Deinited -> ListCoordinator")
    }
    
    private func getItems() -> [RateItem] {
        guard let leadCode = self.leadCode else { return self.items }
        
        let sortedItems = self.items.sorted(by: { (left, _) -> Bool in
            return left.code == leadCode
        })
        
        return sortedItems
    }
    
    private func updateRates() {
        self.dataHandler?.updateExchangeRates(with: self.getItems(), amountForDefaultCurrency: self.amountDefault)
    }
    
}

extension ListCoordinator: ListCoordinatorProtocol {
    
    func requestRates() {
        self.ratesProvider.getExchangeRates(for: self.baseItemCode) { [unowned self] (items, error) in
            if let error = error {
                print("Error: \(error)")
                return
            }
            self.items = items
            
            self.updateRates()
        }
    }
    
    func changeLead(code: BaseCode) {
        self.leadCode = code
        
        self.updateRates()
    }
    
    func changeLead(value: Double) {
        guard let leadCode = self.leadCode else { return }
        guard let rate = self.items.filter({ $0.code == leadCode}).first?.rate else { return }
        self.amountDefault = value / rate

        self.updateRates()
    }
    
}
