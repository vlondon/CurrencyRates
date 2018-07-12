import UIKit

class ListPresenter {
    
   var didChangeRateItems: (([ListItem]) -> Void)?
    
    private let listCoordinator: ListCoordinatorProtocol
    
    init(listCoordinator: ListCoordinatorProtocol) {
        self.listCoordinator = listCoordinator
    }
    
    deinit {
        print("Deinited -> ListPresenter")
    }
    
    private func getExchangeRates() {
        self.listCoordinator.requestRates()
    }
    
}

extension ListPresenter: ListEventHandler {
    
    func didLoadView() {
        self.getExchangeRates()
    }
    
    func didChangeLead(code: BaseCode) {
        self.listCoordinator.changeLead(code: code)
    }
    
    func didChangeLead(value: Double) {
        self.listCoordinator.changeLead(value: value)
    }
    
}

extension ListPresenter: ListDataHandler {
    
    func updateExchangeRates(with rateItems: [RateItem], amountForDefaultCurrency: Double) {
        let listItems = rateItems.map({ ListItem(with: $0, amount: amountForDefaultCurrency) })
        self.didChangeRateItems?(listItems)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) { [weak self] in
            self?.getExchangeRates()
        }
    }
    
}
