import XCTest
@testable import Currencies

class ListCoordinatorTests: XCTestCase {
    
    var coordinator: ListCoordinator!
    
    var baseItemCode: BaseCode!
    var mockRatesProvider: MockListCoordinatorRatesProvider!
    var mockDataHandler: MockDataHandler!
    
    var mockRateItem1 = RateItem(code: "GBP", rate: 1.2)
    var mockRateItem2 = RateItem(code: "USD", rate: 1.9)
    var mockRateItem3 = RateItem(code: "RUB", rate: 12)
    
    override func setUp() {
        super.setUp()
        
        baseItemCode = "GBP"
        mockRatesProvider = MockListCoordinatorRatesProvider()
        mockDataHandler = MockDataHandler()
        
        coordinator = ListCoordinator(ratesProvider: mockRatesProvider, baseItemCode: baseItemCode)
        coordinator.dataHandler = mockDataHandler
    }
    
    func test_WhenRequestRates_ItShouldGetExchangeRatesFromRatesProvider() {
        coordinator.requestRates()
        
        XCTAssertTrue(mockRatesProvider.getExchangeRatesCalled.isCalled)
        XCTAssertEqual(mockRatesProvider.getExchangeRatesCalled.code, baseItemCode)
    }
    
    func test_WhenRequestRates_ItShouldCallDataHandlerToUpdateRates() {
        mockRatesProvider.mockDidGetItemsResult = ([
            mockRateItem1,
            mockRateItem2,
            mockRateItem3
            ], nil)
        coordinator.requestRates()
        
        XCTAssertTrue(mockDataHandler.updateExchangeRatesCalled.isCalled)
        XCTAssertEqual(mockDataHandler.updateExchangeRatesCalled.rateItems, [mockRateItem1, mockRateItem2, mockRateItem3])
    }
    
    func test_WhenChangeLeadCode_ItShouldCallPresenterToUpdateExchangeRates() {
        mockRatesProvider.mockDidGetItemsResult = ([
            mockRateItem1,
            mockRateItem2,
            mockRateItem3
        ], nil)
        coordinator.requestRates()
        
        coordinator.changeLead(code: "USD")
        
        let expectedItems: [RateItem]? = [
            mockRateItem2,
            mockRateItem1,
            mockRateItem3
        ]
        
        XCTAssertTrue(mockDataHandler.updateExchangeRatesCalled.isCalled)
        XCTAssertEqual(mockDataHandler.updateExchangeRatesCalled.rateItems, expectedItems)
        XCTAssertEqual(mockDataHandler.updateExchangeRatesCalled.amountForDefaultCurrency, 100)
    }
    
    func test_WhenChangeLeadValueAfterChangingLeadCode_ItShouldCallPresenterToUpdateExchangeRates() {
        mockRatesProvider.mockDidGetItemsResult = ([
            mockRateItem1,
            mockRateItem2,
            mockRateItem3
            ], nil)
        coordinator.requestRates()
        
        coordinator.changeLead(code: "USD")
        coordinator.changeLead(value: 3)
        
        let expectedItems: [RateItem] = [
            mockRateItem2,
            mockRateItem1,
            mockRateItem3
        ]
        
        let newAmountForDefaultCurrency = 1.5789473684210527 // 3 (new value) / 1.9 (active currency rate)
        
        XCTAssertTrue(mockDataHandler.updateExchangeRatesCalled.isCalled)
        XCTAssertEqual(mockDataHandler.updateExchangeRatesCalled.rateItems, expectedItems)
        XCTAssertEqual(mockDataHandler.updateExchangeRatesCalled.amountForDefaultCurrency, newAmountForDefaultCurrency)
    }
    
    func test_WhenChangeLeadValueBeforeChangingLeadCode_ItShouldCallPresenterToUpdateExchangeRates() {
        mockRatesProvider.mockDidGetItemsResult = ([
            mockRateItem1,
            mockRateItem2,
            mockRateItem3
            ], nil)
        coordinator.requestRates()
        
        mockDataHandler.updateExchangeRatesCalled = (false, nil, nil)
        
        coordinator.changeLead(value: 3)
        
        XCTAssertFalse(mockDataHandler.updateExchangeRatesCalled.isCalled)
    }
    
}

class MockListCoordinatorRatesProvider: RatesProvider {
    
    var mockDidGetItemsResult: ([RateItem], Error?)?
    
    var getExchangeRatesCalled: (isCalled: Bool, code: BaseCode?) = (false, nil)
    
    func getExchangeRates(for code: BaseCode, didGetItems: @escaping (([RateItem], Error?) -> Void)) {
        getExchangeRatesCalled = (true, code)
        
        if let result = mockDidGetItemsResult {
            didGetItems(result.0, result.1)
        }
    }
    
}

class MockDataHandler: ListDataHandler {
    
    var updateExchangeRatesCalled: (isCalled: Bool, rateItems: [RateItem]?, amountForDefaultCurrency: Double?) = (false, nil, nil)
    
    func updateExchangeRates(with rateItems: [RateItem], amountForDefaultCurrency: Double) {
        updateExchangeRatesCalled = (true, rateItems, amountForDefaultCurrency)
    }
    
}
