import Vapor
import MongoKitten
import Foundation

final class User {
    let id: String
    let firstName: String
    let lastName: String
    let email: String
    let password: String
    let avatar: String
    let createdAt: String
    let updatedAt: String
    init(id: String? = nil, firstName: String, lastName: String, email: String, password: String, avatar: String, createdAt: String, updatedAt: String) {
        self.id = id ?? "\(ObjectId.self)"
        self.firstName = firstName
        self.lastName = lastName
        self.email = email
        self.password = password
        self.avatar = avatar
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
    
}

extension User: JSONRepresentable {
    func makeJSON() throws -> JSON {
        return try JSON(node: [
                "id": id,
                "firstName": firstName,
                "lastName": lastName,
                "email": email,
                "password": password,
                "avatar": avatar,
                "createdAt": createdAt
            ])
    }
}

extension User: StringInitializable {
    convenience init?(from string: String) {
        self.init(id: string, firstName: string, lastName: string, email: string, password: string, avatar: string, createdAt: string, updatedAt: string)
    }
}

extension User {
    convenience init?(fromBson bson: Document) {
        self.init(id: bson["_id"].objectIdValue?.hexString, firstName: bson["firstName"].string, lastName: bson["lastName"].string, email: bson["email"].string, password: bson["password"].string, avatar: bson["avatar"].string, createdAt: bson["createdAt"].string, updatedAt: bson["updatedAt"].string)
    }
    
    func makeBSON() -> Document {
        let bson = [
            "firstName": ~firstName,
            "lastName": ~lastName,
            "email": ~email,
            "password": ~password,
            "avatar": ~avatar,
            "createdAt": ~createdAt,
            "updatedAt": ~updatedAt
        ] as Document
        return bson
    }
    
}
