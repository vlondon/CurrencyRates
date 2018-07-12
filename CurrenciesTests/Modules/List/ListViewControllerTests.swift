import XCTest
@testable import Currencies

class ListViewControllerTests: XCTestCase {
    
    var viewController: ListViewController!
    
    var mockListPresenter: MockListPresenter!
    var dispatcher: Dispatcher!
    
    override func setUp() {
        super.setUp()
        
        mockListPresenter = MockListPresenter()
        dispatcher = SyncDispatcher()
        
        viewController = ListViewController(listPresenter: mockListPresenter, dispatcher: dispatcher)
    }
    
    func test_WhenViewDidLoad_ItShouldSetPresenterDidChangeRateItemsCallback() {
        viewController.loadView()
        viewController.viewDidLoad()
        
        XCTAssertNotNil(mockListPresenter.didChangeRateItems)
    }
    
    func test_WhenViewDidLoad_ItShouldTellPresenterThatViewDidLoad() {
        viewController.loadView()
        viewController.viewDidLoad()
        
        XCTAssertTrue(mockListPresenter.didLoadViewCalled)
    }
    
    func test_WhenViewDidLoad_ItShouldAddItemsInTable() {
        viewController.loadView()
        viewController.viewDidLoad()
        
        mockListPresenter.didChangeRateItems?([
            ListItem(with: RateItem(code: "USD", rate: 1.5), amount: 100),
            ListItem(with: RateItem(code: "GBP", rate: 1.2), amount: 100),
            ListItem(with: RateItem(code: "EUR", rate: 1), amount: 100)
            ])
        
        XCTAssertEqual(viewController.tableView.numberOfRows(inSection: 0), 3)
    }
    
    func test_WhenTableCellSelected_ItShouldCallDidChangeRateItemsOnPresenter() {
        viewController.loadView()
        viewController.viewDidLoad()
        
        mockListPresenter.didChangeRateItems?([
            ListItem(with: RateItem(code: "USD", rate: 1.5), amount: 100),
            ListItem(with: RateItem(code: "GBP", rate: 1.2), amount: 100),
            ListItem(with: RateItem(code: "EUR", rate: 1), amount: 100)
        ])
        
        viewController.tableView.delegate?.tableView?(viewController.tableView, didSelectRowAt: IndexPath(row: 1, section: 0))
        
        XCTAssertTrue(mockListPresenter.didChangeLeadCodeCalled.isCalled)
        XCTAssertEqual(mockListPresenter.didChangeLeadCodeCalled.code, "GBP")
    }
    
}

class MockListPresenter: ListEventHandler {
    
    var didChangeRateItems: (([ListItem]) -> Void)?
    
    var didLoadViewCalled = false
    func didLoadView() {
        didLoadViewCalled = true
    }
    
    var didChangeLeadCodeCalled: (isCalled: Bool, code: BaseCode?) = (false, nil)
    func didChangeLead(code: BaseCode) {
        didChangeLeadCodeCalled = (true, code)
    }
    
    var didChangeLeadValueCalled: (isCalled: Bool, value: Double?) = (false, nil)
    func didChangeLead(value: Double) {
        didChangeLeadValueCalled = (true, value)
    }
    
}
