import UIKit
import RxSwift

class HistoryTableViewController: UITableViewController {
    
    var viewModel: ToDoListViewModel!
    var disposeBag: DisposeBag = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = nil
        tableView.dataSource = nil
        viewModel.outputs.history.asObservable()
            .bind(to: tableView.rx.items(cellIdentifier: "HistoryCell"))  {
                (index, action, cell) in
                cell.textLabel?.text = String(describing: action.type) + "--" + action.data.id
                cell.detailTextLabel?.text = action.data.title
        }
        .disposed(by: disposeBag)
        
        viewModel.outputs.historyIndex.asObservable()
            .bind { [weak self] (index) in
                self?.tableView.visibleCells.forEach({ $0.isSelected = false })
                let cell = self?.tableView.cellForRow(at: IndexPath(row: index, section: 0))
                cell?.isSelected = true
        }
        .disposed(by: disposeBag)
    }

}
