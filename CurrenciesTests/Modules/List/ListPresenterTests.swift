import XCTest
@testable import Currencies

class ListPresenterTests: XCTestCase {
    
    var presenter: ListPresenter!
    
    var mockListCoordinator: MockListCoordinator!
    
    override func setUp() {
        super.setUp()
        
        mockListCoordinator = MockListCoordinator()
        
        presenter = ListPresenter(listCoordinator: mockListCoordinator)
    }
    
    func test_WhenDidLoadView_ItShouldRequestRates() {
        let expectation = self.expectation(description: "It should request rates")
        
        mockListCoordinator.requestRatesCalled = { isCalled in
            XCTAssertTrue(isCalled)
            expectation.fulfill()
        }
        
        presenter.didLoadView()
        
        self.wait(for: [expectation], timeout: 1)
    }
    
    func test_WhenDidChangeLeadCode_ItShouldTellCoordinatorToChangeLeadCode() {
        presenter.didChangeLead(code: "USD")
        
        XCTAssertTrue(mockListCoordinator.changeLeadCodeCalled.isCalled)
        XCTAssertEqual(mockListCoordinator.changeLeadCodeCalled.code, "USD")
    }
    
    func test_WhenDidChangeLeadValue_ItShouldTellCoordinatorToChangeLeadValue() {
        presenter.didChangeLead(value: 1)
        
        XCTAssertTrue(mockListCoordinator.changeLeadValueCalled.isCalled)
        XCTAssertEqual(mockListCoordinator.changeLeadValueCalled.value, 1)
    }
    
    func test_WhenDidChangeRateItems_ItShouldCallDidChangeRateItems() {
        let expectation = self.expectation(description: "It should call didChangeRateItems")
        
        presenter.didChangeRateItems = { items in
            XCTAssertEqual(items.count, 1)
            XCTAssertEqual(items.first?.title, "USD")
            XCTAssertEqual(items.first?.value, 150)
            expectation.fulfill()
        }
        
        presenter.updateExchangeRates(with: [
            RateItem(code: "USD", rate: 1.5)
        ], amountForDefaultCurrency: 100)
        
        self.wait(for: [expectation], timeout: 1)
    }
    
    func test_WhenDidChangeRateItems_ItShouldRequestRates() {
        let expectation = self.expectation(description: "It should call request rates")

        mockListCoordinator.requestRatesCalled = { isCalled in
            XCTAssertTrue(isCalled)
            expectation.fulfill()
        }

        presenter.updateExchangeRates(with: [
            RateItem(code: "USD", rate: 1.5)
        ], amountForDefaultCurrency: 100)

        self.wait(for: [expectation], timeout: 2)
    }
    
}

class MockListCoordinator: ListCoordinatorProtocol {
    
    var requestRatesCalled: ((Bool) -> Void)?
    func requestRates() {
        requestRatesCalled?(true)
    }
    
    var changeLeadCodeCalled: (isCalled: Bool, code: BaseCode?) = (false, nil)
    func changeLead(code: BaseCode) {
        changeLeadCodeCalled = (true, code)
    }
    
    var changeLeadValueCalled: (isCalled: Bool, value: Double?) = (false, nil)
    func changeLead(value: Double) {
        changeLeadValueCalled = (true, value)
    }
    
}
