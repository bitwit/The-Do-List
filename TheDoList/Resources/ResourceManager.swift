import Foundation
import RxSwift

typealias Resource = ResourceType & Codable & Equatable & Hashable

protocol ResourceType {

    static var name: String { get }
    
    var id: String { get }
}

class ResourceManager<R: Resource> {
    
    let items: Variable<[R]> = Variable([])
    let itemChanged: PublishSubject<R> = PublishSubject()
    
    init() {
       load()
    }
    
    func add(_ item: R) {
        items.value.append(item)
        save()
    }
    
    func prepend(_ item: R) {
        items.value.insert(item, at: 0)
        save()
    }
    
    func insert(_ item: R, at index: Int) {
        items.value.insert(item, at: index)
        save()
    }
    
    func update(_ item: R) {
        guard let idx = items.value.index(where:{ $0 == item }) else {
           return
        }
        items.value[idx] = item
        itemChanged.onNext(item)
        save()
    }
    
    func delete(_ item: R) {
        guard let idx = items.value.index(where:{ $0 == item }) else {
            return
        }
        items.value.remove(at: idx)
        save()
    }
    
    func load() {
        var saveLocation = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).last!
        saveLocation += "/save.dat"
        
        guard let data = FileManager.default.contents(atPath: saveLocation) else {
            return
        }
        
        let unarchiver = NSKeyedUnarchiver(forReadingWith: data)
        guard let items = unarchiver.decodeDecodable([R].self, forKey: "items") else {
            fatalError("Failed to load items")
        }
        self.items.value = items
    }
    
    private func save() {
        let archiver = NSKeyedArchiver()
        var saveLocation = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).last!
        saveLocation += "/save.dat"
        let url = URL.init(fileURLWithPath: saveLocation)
        do {
            try archiver.encodeEncodable(items.value, forKey: "items")
            archiver.finishEncoding()
            try archiver.encodedData.write(to: url)
        } catch {
            print(error)
            fatalError("Failed to write to \(saveLocation)")
        }
    }
    
}
