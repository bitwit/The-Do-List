# The Do List - A MVVM Architecture To-Do List built with RxSwift

![Example](./the-do-list-app.gif)

Features:
- MVVM Architecture
- Most of the code  built with a generic `Resource` type for future development consideration
  - `Resource`s must be `Equatable & Hashable & Codable`
- Undo/Redo functionality for all CRUD operations
- Animated Insertion/Deletion by diffing
- Saving to disk

Future considerations for fun and profit 🎉:
- Implement syncing with a web service
- More operations that challenge MVVM/RxSwift
 - e.g. Timer countdown on expiring item
- Performance tweaking
