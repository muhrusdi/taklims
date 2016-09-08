import Vapor
import MongoKitten
import Foundation

final class Taklim {
    let id: String
    let materi: String
    let pemateri: String
    let note: String
    let date: String
    let time: String
    let tempat: String
    let pamflet: String
    let lokasi: Lokasi
    let createdAt: String
    let updatedAt: String
    let userId: String
    let nameUser: String
    init(id: String? = nil, materi: String, pemateri: String, note: String, date: String, time: String, tempat: String, pamflet: String, lokasi: Lokasi, createdAt: String, updatedAt: String, userId: String, nameUser: String) {
        self.id = id ?? "\(ObjectId.self)"
        self.materi = materi
        self.pemateri = pemateri
        self.note = note
        self.date = date
        self.time = time
        self.tempat = tempat
        self.pamflet = pamflet
        self.lokasi = lokasi
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.userId = userId
        self.nameUser = nameUser
    }
}

extension Taklim: StringInitializable {
    convenience init?(from string: String) {
        self.init(id: string, materi: string, pemateri: string, note: string, date: string, time: string, tempat: string, pamflet: string, lokasi: Lokasi(latitude: string, longitude: string), createdAt: string, updatedAt: string, userId: string, nameUser: string)
    }
}

extension Taklim: JSONRepresentable {
    func makeJSON() throws -> JSON {
        guard let time = Double(time) else {
            throw Abort.badRequest
        }
        let timeInt = humanReadablePostTime(time: time)
        return try JSON(node: [
                "id": id,
                "materi": materi,
                "pemateri": pemateri,
                "note": note,
                "date": date,
                "time": timeInt,
                "sort": self.time,
                "tempat": tempat,
                "pamflet": pamflet,
                "lokasi": try JSON(node: [
                    "latitude": lokasi.latitude,
                    "longitude": lokasi.longitude
                ]),
                "createdAt": createdAt,
                "updatedAt": updatedAt,
                "userId": userId,
                "nameUser": nameUser
            ])
    }
    
    private func humanReadablePostTime(time: Double) -> String {
        let newsDate = NSDate(timeIntervalSince1970: time)
        let delta = abs(Int(newsDate.timeIntervalSinceNow))
        
        if delta < 3 {
            return "just now"
        } else if delta < 60 {
            return "\(delta) seconds ago"
        } else if delta < 120 {
            return "1 minute ago"
        } else if delta < 3600 {
            return "\(delta / 60) minutes ago"
        } else if delta < 7200 {
            return "1 hour ago"
        } else if delta < 86400 {
            return "\(delta / 3600) hours ago"
        } else if delta < 172800 {
            return "1 day ago"
        }
        
        return "\((delta / 86400) + 1) days ago"
    }
}

extension Taklim {
    convenience init?(fromBson bson: Document) {
        self.init(id: bson["_id"].objectIdValue?.hexString, materi: bson["materi"].string, pemateri: bson["pemateri"].string, note: bson["note"].string, date: bson["date"].string, time: bson["time"].string, tempat: bson["tempat"].string, pamflet: bson["pamflet"].string, lokasi: Lokasi(latitude: bson["lokasi"]["latitude"].string, longitude: bson["lokasi"]["longitude"].string), createdAt: bson["createdAt"].string, updatedAt: bson["updatedAt"].string, userId: bson["userId"].string, nameUser: bson["nameUser"].string)
    }
    func makeBSON() -> Document {
        let bson = [
            "materi": ~materi,
            "pemateri": ~pemateri,
            "note": ~note,
            "time": ~time,
            "date": ~date,
            "tempat": ~tempat,
            "pamflet": ~pamflet,
            "lokasi": [
                "latitude": ~lokasi.latitude,
                "longitude": ~lokasi.longitude
            ],
            "createdAt": ~createdAt,
            "updatedAt": ~updatedAt,
            "userId": ~userId,
            "nameUser": ~nameUser
        ] as Document
        return bson
    }
}

struct Lokasi {
    var latitude: String
    var longitude: String
}
