import Foundation

public struct DiffCalculator {
    
    public enum DataDiffChange {
        case added(Int)
        case removed(Int)
    }
    
    public let changes: [DataDiffChange]
    
    public init<T: Hashable>(_ initialItems: [T], _ changedItems: [T]) {
        let setOne = Set(initialItems)
        let setTwo = Set(changedItems)
        
        let removed = setOne.subtracting(setTwo)
        let added = setTwo.subtracting(setOne)
        
        var changes = [DataDiffChange]()
        for (i, item) in initialItems.reversed().enumerated() {
            let arrayIndex = (initialItems.count - 1) - i
            if removed.contains(item) {
                changes.append(.removed(arrayIndex))
            }
        }
        
        for (i, item) in changedItems.enumerated() {
            if added.contains(item) {
                changes.append(.added(i))
            }
        }
        
        self.changes = changes
    }
}
