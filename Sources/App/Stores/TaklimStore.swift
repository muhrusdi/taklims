import Vapor
import MongoKitten
import Foundation

final class TaklimStore {
    var taklimCollection: MongoKitten.Collection!
    let nameCollection = "taklimCollection"
    
    static let sharedInstance = try? TaklimStore()
    init() throws {
        if let repository = MongoRepository.sharedIsntance {
            taklimCollection = repository.database[nameCollection]
        } else {
            throw MongoRepositoryError.CouldNotConnect
        }
    }
    
    func index() -> [Taklim]? {
        var results = [Taklim]()
        
        let cursors = try? taklimCollection.find()
        for cursor in cursors! {
            let taklim = Taklim(fromBson: cursor)
            results.append(taklim!)
        }
        return results
    }
    
    func getById(id: String) -> [Taklim]? {
        var u = [Taklim]()
        let cursors = try? taklimCollection.find(matching: "userId" == id)
        for cursor in cursors! {
            let t = Taklim(fromBson: cursor)
            u.append(t!)
        }
        return u
    }
    
    func insert(taklim: Taklim, completion: (_ bool: Bool) -> Void) throws {
        let taklimInsert = taklim.makeBSON()
        do {
            try taklimCollection.insert(taklimInsert)
            completion(true)
        } catch {
            completion(false)
            throw MongoRepositoryError.CouldNotInsert
        }
    }
    
    func delete(id: String, completion: (_ bool: Bool) -> Void) {
        do {
            if try taklimCollection.count(matching: "_id" == ObjectId(id)) != 0 {
                try taklimCollection.remove(matching: "_id" == ObjectId(id))
                completion(true)
            } else if try taklimCollection.count(matching: "userId" == id) != 0 {
                try taklimCollection.remove(matching: "userId" == id)
                completion(true)
            } else {
                completion(false)
            }
            
        } catch {
            completion(false)
        }
    }
    
}
