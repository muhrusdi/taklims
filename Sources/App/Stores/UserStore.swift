import Vapor
import MongoKitten
import Foundation

final class UserStore {
    var userCollection: MongoKitten.Collection!
    let nameCollection = "userCollection"
    
    static let sharedInstance = try? UserStore()
    init() throws {
        if let repository = MongoRepository.sharedIsntance {
            userCollection = repository.database[nameCollection]
        } else {
            throw MongoRepositoryError.CouldNotConnect
        }
    }
    
    func register(user: User, completion: (_ bool: Bool) -> Void) {
        do {
            if try userCollection.count(matching: "email" == user.email) == 0 {
                try userCollection.insert(user.makeBSON())
                completion(true)
            } else {
                completion(false)
            }
        } catch {
            print("Register Failed")
        }
    }
    
    func getEmail(email: String) -> User? {
        var u: User!
        do {
            if let user = try? userCollection.findOne(matching: "email" == email) {
                if user != nil {
                    u = User(fromBson: user!)
                }
            } else {
                return nil
            }
        }
        return u
    }
    
    func login(email: String, password: String, completion: (_ bool: Bool, _ user: User?) throws -> Void) throws {
        
        let passwordHash = try drop.hash.make(password)
        guard let u = try? userCollection.findOne(matching: "email" == email && "password" == passwordHash) else {
            throw Abort.notFound
        }
        
        if u != nil {
            try? completion(true, User(fromBson: u!))
        } else {
            try? completion(false, nil)
        }
    }
}
