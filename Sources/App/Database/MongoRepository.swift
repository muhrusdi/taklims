import MongoKitten

final class MongoRepository {
    let host = "ds040489.mlab.com"
    let username = "muhrusdi"
    let pass = "muhammadr"
    let port = "40489"
    let db = "taklim"
    
    // mongodb://<dbuser>:<dbpassword>@ds040489.mlab.com:40489/taklim
    
    static let sharedIsntance = try? MongoRepository()
    var server: MongoKitten.Server!
    var database: MongoKitten.Database {
        return server[db]
    }
    
    init() throws {
        try server = MongoKitten.Server("mongodb://\(username):\(pass)@\(host):\(port)/taklim", automatically: true)
    }
}

enum MongoRepositoryError: Error {
    case CouldNotConnect
    case CouldNotInsert
}
