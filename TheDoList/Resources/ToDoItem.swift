import Foundation

struct ToDoItem: Codable, Equatable {
    
    var id: String
    var title: String
    
    init(title: String) {
        self.id = UUID().uuidString
        self.title = title
    }
}

func == (_ lhs: ToDoItem, _ rhs: ToDoItem) -> Bool {
   return lhs.id == rhs.id
}

extension ToDoItem: ResourceType {
    static let name: String = "todoitem"
}

extension ToDoItem: Hashable {
    var hashValue: Int {
        return id.hashValue
    }
}
