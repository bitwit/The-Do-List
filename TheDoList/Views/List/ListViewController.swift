import UIKit
import RxSwift
import RxCocoa

class ListViewController: UIViewController {

    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var addButton: UIBarButtonItem!
    @IBOutlet weak var undoButton: UIBarButtonItem!
    @IBOutlet weak var redoButton: UIBarButtonItem!
    
    var viewModel: ToDoListViewModel!
    var disposeBag: DisposeBag = DisposeBag()
    var editingCellDisposeBag: DisposeBag?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let viewModel: ToDoListViewModel = self.viewModel
        
        let dataSource: GenericDataSource<ToDoItem> = GenericDataSource(collectionView: collectionView, cellDescriptor: CellDescriptor(reuseIdentifier: "ItemCell", configure: {
            [weak self] (itemCell: ToDoItemCell, item: ToDoItem, indexPath: IndexPath) in
            self?.configure(itemCell, data: item, indexPath: indexPath)
        }))
        viewModel.outputs.items.asObservable()
            .bind(to: collectionView.rx.items(dataSource: dataSource))
            .disposed(by: disposeBag)
        
        viewModel.outputs.currentEditingItemIndex.asObservable()
            .previousAndCurrentValues()
            .bind { [weak self] (oldIdx, newIdx) in
                self?.deselect(oldIdx)
                self?.select(newIdx, viewModel: viewModel)
        }
        .disposed(by: disposeBag)
        
        viewModel.outputs.itemChanged.bind { [weak self] (item, index) in
            guard let idx = index else { return }
            let indexPath = IndexPath(row: idx, section: 0)
            guard let cell = self?.collectionView.cellForItem(at: indexPath) as? ToDoItemCell else { return }
            self?.configure(cell, data: item, indexPath: indexPath)
        }
        .disposed(by: disposeBag)

        Observable.combineLatest(viewModel.outputs.history.asObservable(), viewModel.outputs.historyIndex.asObservable())
            .bind { [weak self] (history, historyIndex) in
                guard history.isNotEmpty else {
                    self?.undoButton.isEnabled = false
                    self?.redoButton.isEnabled = false
                    return
                }
                self?.undoButton.isEnabled = (historyIndex > -1)
                self?.redoButton.isEnabled = (historyIndex < history.count - 1)
        }
        .disposed(by: disposeBag)
        
        addButton.rx.tap
            .bind(to: viewModel.inputs.onNewItem)
            .disposed(by: disposeBag)
        
        undoButton.rx.tap
            .bind(to: viewModel.inputs.onUndo)
            .disposed(by: disposeBag)
        
        redoButton.rx.tap
            .bind(to: viewModel.inputs.onRedo)
            .disposed(by: disposeBag)
        
        collectionView.rx.itemSelected
            .bind(to: viewModel.inputs.onItemSelected)
            .disposed(by: disposeBag)
    }
    
    func select(_ indexPath: IndexPath?, viewModel: ToDoListViewModel) {
        guard let idx = indexPath
            , let cell = collectionView.cellForItem(at: idx) as? ToDoItemCell else { return }
        
        let editDisposeBag = DisposeBag()
        self.editingCellDisposeBag = editDisposeBag
        
        cell.select()
        
        cell.onItemTitleChanged
            .bind(to: viewModel.inputs.onItemTitleChange)
            .disposed(by: editDisposeBag)
        
        cell.deleteButton.rx.tap.asObservable()
            .map { _ -> ToDoItem in cell.model }
            .bind(to: viewModel.inputs.onDeleteItem)
            .disposed(by: editDisposeBag)
    }
    
    func deselect(_ indexPath: IndexPath?) {
        guard let idx = indexPath
            , let cell = collectionView.cellForItem(at: idx) as? ToDoItemCell else { return }
        cell.deselect()
    }
    
    func configure(_ cell: ToDoItemCell, data: ToDoItem, indexPath: IndexPath) {
        cell.model = data
        if let idx = viewModel.outputs.currentEditingItemIndex.value, indexPath == idx {
            select(indexPath, viewModel: viewModel)
        }
    }


}

