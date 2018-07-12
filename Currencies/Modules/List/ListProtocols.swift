import Foundation

protocol ListCoordinatorProtocol {
    func requestRates()
    func changeLead(code: BaseCode)
    func changeLead(value: Double)
}

protocol ListDataHandler: class {
    func updateExchangeRates(with rateItems: [RateItem], amountForDefaultCurrency: Double)
}

protocol ListEventHandler {
    var didChangeRateItems: (([ListItem]) -> Void)? { get set }
    
    func didLoadView()
    func didChangeLead(code: BaseCode)
    func didChangeLead(value: Double)
}
