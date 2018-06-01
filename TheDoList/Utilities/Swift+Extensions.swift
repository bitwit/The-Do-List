import Foundation

extension Optional {
    
    var isNil: Bool {
        switch self {
        case .none:
            return true
        default:
            return false
        }
    }
    
    var isNotNil: Bool {
        return !isNil
    }
}

extension Array {
    
    var isNotEmpty: Bool {
        return !isEmpty
    }
    
    mutating func remove(where predicate: (Element) -> Bool) {
        var new = self
        for i in (0..<count).reversed() {
            if predicate(new[i]) {
                new.remove(at: i)
            }
        }
    }
}

infix operator !!

public func !! <T>(wrapped: T?, failureText: @autoclosure () -> String) -> T { if let x = wrapped { return x }
    fatalError(failureText())
}
