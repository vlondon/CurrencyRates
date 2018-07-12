import UIKit

class MainViewController: UIViewController {
    
    @IBAction func showCurrenciesAction(_ sender: UIButton) {
        let listCoordinator = ListCoordinator(ratesProvider: NetworkLayer(), baseItemCode: "EUR")
        let listPresenter = ListPresenter(listCoordinator: listCoordinator)
        listCoordinator.dataHandler = listPresenter
        let currenciesListViewController = ListViewController(listPresenter: listPresenter)
        
        self.navigationController?.pushViewController(currenciesListViewController, animated: true)
    }
    
}

