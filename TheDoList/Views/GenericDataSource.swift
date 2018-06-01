import UIKit
import RxSwift
import RxCocoa

struct CellDescriptor<R: Resource> {
    let reuseIdentifier: String
    let configure: (UICollectionViewCell, R, IndexPath) -> Void
    
    init<C: UICollectionViewCell>(reuseIdentifier: String, configure: @escaping (C, R, IndexPath) -> Void) {
        self.reuseIdentifier = reuseIdentifier
        self.configure = { cell, item, indexPath in
            configure(cell as! C, item, indexPath)
        }
    }
}

class GenericDataSource<R: Resource>: NSObject, UICollectionViewDataSource {
    
    var cellDescriptor: CellDescriptor<R>
    var collectionView: UICollectionView
    
    var currentItems: [R] = []
    internal var sizeSnapshot: Int?
    
    init(collectionView: UICollectionView, cellDescriptor: CellDescriptor<R>) {
        
        self.collectionView = collectionView
        self.cellDescriptor = cellDescriptor
        super.init()
    }
    
    func applyDiff(oldItems: [R], newItems: [R]) {
        let diff = DiffCalculator(oldItems, newItems)
        guard diff.changes.isNotEmpty else { return }
        
        sizeSnapshot = currentItems.count
        currentItems = newItems
        collectionView.performBatchUpdates({
            diff.changes.forEach { (change) in
                switch change {
                case .added(let index):
                    sizeSnapshot? += 1
                    collectionView.insertItems(at: [IndexPath(row: index, section: 0)])
                case .removed(let index):
                    sizeSnapshot? -= 1
                    collectionView.deleteItems(at: [IndexPath(row: index, section: 0)])
                }
            }
        }, completion: nil)

        sizeSnapshot = nil
    }

    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
       return sizeSnapshot ?? currentItems.count
    }

    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellDescriptor.reuseIdentifier, for: indexPath)
        cellDescriptor.configure(cell, currentItems[indexPath.row], indexPath)
        return cell
    }

}

extension GenericDataSource: RxCollectionViewDataSourceType {
    
    func collectionView(_ collectionView: UICollectionView, observedEvent: Event<[R]>) -> Void {
        switch observedEvent {
        case .next(let items):
            applyDiff(oldItems: currentItems, newItems: items)
        default:
            break
        }
    }
}
