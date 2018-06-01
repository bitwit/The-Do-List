import Foundation

typealias TextChange = (NSRange, String)

func apply(textChanges: [TextChange], to string: String) -> String {
    var moddedString = string as NSString
    textChanges.forEach { change in
        let (range, text) = change
        moddedString = (moddedString.replacingCharacters(in: range, with: text) as NSString)
    }
    return moddedString as String
}

func concatenateActions<R: Resource>(_ actions: [Action<R>]) -> [Action<R>] {
    return actions.reduce([]) { (prev, next) -> [Action<R>] in
        
        guard let last = prev.last else {
            return [next]
        }
        
        switch (next.type, last.type) {
        case (.editTitle(let changes), .editTitle(let lastChanges)) where last.data == next.data:
            let newActions = Action(type: .editTitle(lastChanges + changes), data: last.data)
            return Array(prev.dropLast() + [newActions])
        default:
            return prev + [next]
        }
    }
}
