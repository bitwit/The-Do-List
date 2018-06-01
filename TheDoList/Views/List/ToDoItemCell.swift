import Foundation
import UIKit
import RxSwift

class ToDoItemCell: UICollectionViewCell {
    
    @IBOutlet weak var titleTextView: UITextView!
    @IBOutlet weak var deleteButton: UIButton!
    
    var model: ToDoItem! {
        didSet {
            if false == titleTextView.isFirstResponder {
                titleTextView.text = model.title
            }
        }
    }
    var onItemTitleChanged: PublishSubject<(ToDoItem, NSRange, String)> = PublishSubject()

    override func awakeFromNib() {
        super.awakeFromNib()
        titleTextView.delegate = self
        deselect()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        deselect()
    }
    
    func select() {
        contentView.backgroundColor = UIColor.groupTableViewBackground
        titleTextView.isUserInteractionEnabled = true
        titleTextView.isSelectable = true
        titleTextView.isEditable = true
        titleTextView.becomeFirstResponder()
        deleteButton.isHidden = false
    }
    
    func deselect() {
        contentView.backgroundColor = .white
        titleTextView.resignFirstResponder()
        titleTextView.isUserInteractionEnabled = false
        titleTextView.isSelectable = false
        titleTextView.isEditable = false
        deleteButton.isHidden = true
    }
}

extension ToDoItemCell: UITextViewDelegate {
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if text == "\n" || text == "\t" {
            textView.resignFirstResponder()
            return false
        }
        onItemTitleChanged.onNext((model, range, text))
        return true
    }

}
