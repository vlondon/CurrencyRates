import UIKit

class ListViewController: UIViewController {
    
    private var listPresenter: ListEventHandler
    private let dispatcher: Dispatcher
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var currentValueField: UITextField!
    
    private var items: [ListItem] = []
    private var active: (item: ListItem, indexPath: IndexPath)?
    
    init(listPresenter: ListEventHandler, dispatcher: Dispatcher = MainAsyncDispatcher()) {
        self.listPresenter = listPresenter
        self.dispatcher = dispatcher
        
        let nibName = "ListViewController"
        super.init(nibName: nibName, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        print("Deinited -> ListViewController")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Rates"
        
        self.tableView.dataSource = self
        self.tableView.delegate = self
        self.tableView.register(UINib(nibName: ListViewCell.cellIdentifier, bundle: nil), forCellReuseIdentifier: ListViewCell.cellIdentifier)
        
        self.updateTable()
        
        currentValueField.delegate = self
        currentValueField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(adjustForKeyboard), name: Notification.Name.UIKeyboardWillHide, object: nil)
        notificationCenter.addObserver(self, selector: #selector(adjustForKeyboard), name: Notification.Name.UIKeyboardWillChangeFrame, object: nil)
        
        self.listPresenter.didChangeRateItems = { [unowned self] items in
            print("+ update rates")
            self.items = items
            self.dispatcher.dispatch {
                self.updateTable()
            }
        }
        
        self.listPresenter.didLoadView()
    }
    
    private func setActiveItem(to activeItem: (item: ListItem, indexPath: IndexPath)?) {
        self.active = activeItem
        
        self.updateNavigationButton()
        
        if let activeItemTitle = activeItem?.item.title {
            self.listPresenter.didChangeLead(code: activeItemTitle)
        }
    }
    
    private func updateNavigationButton() {
        guard active?.indexPath != nil else {
            self.navigationItem.rightBarButtonItem = nil
            return
        }
        
        let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(ListViewController.doneEditing))
        self.navigationItem.rightBarButtonItem = doneButton
    }
    
    @objc func doneEditing() {
        self.resetActive()
    }
    
    @objc func textFieldDidChange(_ textField: UITextField) {
        self.reloadActiveRow()
        guard let text = textField.text, let value = Double(text) else {
            self.listPresenter.didChangeLead(value: 0)
            return
        }
        self.listPresenter.didChangeLead(value: value)
    }
    
    @objc func adjustForKeyboard(notification: Notification) {
        guard let userInfo = notification.userInfo else { return }
        
        let keyboardScreenEndFrame = (userInfo[UIKeyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        let keyboardViewEndFrame = view.convert(keyboardScreenEndFrame, from: view.window)
        
        if notification.name == Notification.Name.UIKeyboardWillHide {
            self.tableView.contentInset = .zero
        } else {
            self.tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: keyboardViewEndFrame.height, right: 0)
        }
        
        self.tableView.scrollIndicatorInsets = self.tableView.contentInset
    }
    
    private func reloadActiveRow() {
        guard let activePath = self.active?.indexPath else { return }
        self.tableView.reloadRows(at: [activePath], with: .none)
    }
    
    private func resetActive() {
        guard let activeIndexPath = self.active?.indexPath else { return }
        self.setActiveItem(to: nil)
        
        self.currentValueField.resignFirstResponder()
        
        guard let activeCell = tableView.cellForRow(at: activeIndexPath) as? ListViewCell else { return }
        activeCell.makeInactive()
    }
    
    private func updateTable() {
        self.tableView.reloadData()
    }
    
}

extension ListViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let itemData = self.items[indexPath.row]
        let firstIndexPath = IndexPath(row: 0, section: 0)
        self.setActiveItem(to: (itemData, firstIndexPath))
        
        self.currentValueField.text = itemData.getFormattedValue()
        self.currentValueField.becomeFirstResponder()
        
        tableView.reloadData()
    }
    
}

extension ListViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: ListViewCell.cellIdentifier, for: indexPath) as? ListViewCell else { fatalError() }
        
        let itemData = self.items[indexPath.row]
        let isActive = itemData.title == self.active?.item.title
        let inputValue = isActive ? self.currentValueField.text ?? "" : itemData.getFormattedValue()
        
        let itemDisplayable = ListViewItemDisplayable(
            image: itemData.image,
            title: itemData.title,
            description: itemData.description,
            inputValue: inputValue,
            isActive: isActive
        )
        cell.update(with: itemDisplayable)
        
        return cell
    }
    
}

extension ListViewController: UITextFieldDelegate {
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        self.tableView.reloadData()
    }
    
}
