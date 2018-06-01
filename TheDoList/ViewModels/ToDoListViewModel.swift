import Foundation
import RxSwift

class Action<R: Resource> {
    enum ActionType {
        case add
        case remove(Int)
        case editTitle([TextChange])
    }
    let type: ActionType
    let data: R
    
    init(type: ActionType, data: R) {
        self.type = type
        self.data = data
    }
}

class ToDoListViewModel {
    
    struct Inputs {
        let onNewItem: PublishSubject<Void> = PublishSubject()
        let onItemSelected: PublishSubject<IndexPath> = PublishSubject()
        let onDeleteItem: PublishSubject<ToDoItem> = PublishSubject()
        let onItemTitleChange: PublishSubject<(ToDoItem, NSRange, String)> = PublishSubject()
        
        let onUndo: PublishSubject<Void> = PublishSubject()
        let onRedo: PublishSubject<Void> = PublishSubject()
    }
    
    struct Outputs {
        let history: Variable<[Action<ToDoItem>]> = Variable([])
        let historyIndex: Variable<Int> = Variable(-1)
        
        let items: Variable<[ToDoItem]>
        let currentEditingItemIndex: Variable<IndexPath?> = Variable(nil)
        let currentEditingItem: Variable<ToDoItem?> = Variable(nil)
        let itemChanged: Observable<(ToDoItem, Int?)>
    
        init(resourceManager: ResourceManager<ToDoItem>) {
            self.items = resourceManager.items
            self.itemChanged = resourceManager.itemChanged.map {
                ($0, resourceManager.items.value.index(of: $0))
            }
        }
    }
    
    var inputs: Inputs
    var outputs: Outputs
    let disposeBag: DisposeBag = DisposeBag()
    let resourceManager: ResourceManager<ToDoItem>
    
    public init(resourceManager: ResourceManager<ToDoItem>) {
        
        let inputs = Inputs()
        let outputs = Outputs(resourceManager: resourceManager)
        self.inputs = inputs
        self.outputs = outputs
        self.resourceManager = resourceManager

        inputs.onNewItem.subscribe(onNext: { [weak self] _ in
            if nil != outputs.currentEditingItem.value {
                outputs.currentEditingItemIndex.value = nil
                outputs.currentEditingItem.value = nil
            }
            
            let newItem = ToDoItem(title: "\(outputs.items.value.count + 1). New Item")
            self?.applyNew(Action(type: .add, data: newItem))
        })
        .disposed(by: disposeBag)

        inputs.onItemSelected.subscribe(onNext: { indexPath in
            outputs.currentEditingItemIndex.value = indexPath
            outputs.currentEditingItem.value = resourceManager.items.value[indexPath.row]
        })
        .disposed(by: disposeBag)
        
        inputs.onItemTitleChange.bind { [weak self] todoItem, range, text in
            self?.applyNew(Action<ToDoItem>(type: .editTitle([(range, text)]), data: todoItem) )
        }
        .disposed(by: disposeBag)
        
        inputs.onDeleteItem.bind { [weak self] (todoItem) in
            guard let idx = outputs.items.value.index(of: todoItem) else { return }
            outputs.currentEditingItemIndex.value = nil
            outputs.currentEditingItem.value = nil
            self?.applyNew(Action(type: .remove(idx), data: todoItem))
        }
        .disposed(by: disposeBag)
        
        inputs.onUndo.bind { [weak self] _ in
            self?.undo()
        }
        .disposed(by: disposeBag)
        
        inputs.onRedo.bind { [weak self] _ in
            self?.redo()
        }
        .disposed(by: disposeBag)
    }
    
    private func undo() {
        var historyIndex = outputs.historyIndex.value
        var history = outputs.history.value
        guard history.isNotEmpty
            , historyIndex > -1 else { return }
        
        let action = history[historyIndex]
        historyIndex -= 1
        reverse(action: action)
        outputs.historyIndex.value = historyIndex
    }
    
    private func redo() {
        var historyIndex = outputs.historyIndex.value
        var history = outputs.history.value
        guard history.isNotEmpty
            , historyIndex < history.count - 1 else { return }
        
        historyIndex += 1
        let action = history[historyIndex]
        perform(action: action)
        outputs.historyIndex.value = historyIndex
    }
    
    private func applyNew(_ action: Action<ToDoItem>) {
        perform(action: action)
        
        let historyIndex = outputs.historyIndex.value
        var history: [Action<ToDoItem>] = []
        if historyIndex > -1 {
            history += outputs.history.value[0...historyIndex]
        }
        history.append(action)
        history = concatenateActions(history)
        outputs.history.value = history
        outputs.historyIndex.value = history.count - 1
    }
    
    private func perform(action: Action<ToDoItem>) {
        switch action.type {
        case .add:
            resourceManager.prepend(action.data)
        case .remove:
            resourceManager.delete(action.data)
        case .editTitle(let changes):
            var newData = action.data
            newData.title = apply(textChanges: changes, to: newData.title)
            resourceManager.update(newData)
        }
    }
    
    private func reverse(action: Action<ToDoItem>) {
        switch action.type {
        case .add:
            resourceManager.delete(action.data)
        case .remove(let idx):
            resourceManager.insert(action.data, at: idx)
        case .editTitle:
            resourceManager.update(action.data)
        }
    }
    
}
