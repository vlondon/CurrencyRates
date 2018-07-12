import UIKit

struct ListViewItemDisplayable {
    let image: UIImage?
    let title: String
    let description: String
    let inputValue: String
    let isActive: Bool
}

class ListViewCell: UITableViewCell {
    
    static let cellIdentifier = "ListViewCell"
    
    var didBecomeActive: (() -> Void)?
    
    @IBOutlet weak var mainImage: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var inputField: UITextField!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        mainImage.layer.masksToBounds = true
        mainImage.layer.cornerRadius = mainImage.frame.size.width / 2
        mainImage.layer.borderColor = UIColor.lightGray.cgColor
        mainImage.layer.borderWidth = 1.0
    }
    
    override func prepareForReuse() {
        mainImage.image = nil
        titleLabel.text = ""
        descriptionLabel.text = ""
        inputField.text = ""
    }
    
    func update(with item: ListViewItemDisplayable) {
        mainImage.image = item.image
        titleLabel.text = item.title
        descriptionLabel.text = item.description
        inputField.text = item.inputValue
        inputField.textColor = item.isActive ? .red : .black
    }
    
    func makeInactive() {
        inputField.textColor = .black
    }
    
}

extension ListViewCell: UITextFieldDelegate {
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        self.didBecomeActive?()
    }
    
}
