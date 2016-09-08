import Vapor
import HTTP
import Routing
import Foundation

class MainCollection: RouteCollection {
    typealias Wrapped = HTTP.Responder
    func build<Builder : RouteBuilder>(_ builder: Builder) where Builder.Value == Wrapped {
        let API = builder.grouped("api")
        let v1 = API.grouped("v1")
        let taklim = v1.grouped("taklim")
        let user = v1.grouped("user")
        
        /* ------------ TAKLIM ------------ */
        
        // GET
        taklim.get("/") { _ in
            var json: [Taklim]!
            if let taklimStore = TaklimStore.sharedInstance {
                json = taklimStore.index()
            }
            return try JSON(json.map { try $0.makeJSON()} )
        }
        
        // POST
        taklim.post("/:id") { request in
            var json: Response!
            guard let materi = request.data["materi"]?.string,
                let pemateri = request.data["pemateri"]?.string,
                let note = request.data["note"]?.string,
                let date = request.data["date"]?.string,
                let tempat = request.data["tempat"]?.string,
                let pamflet = request.data["pamflet"]?.string,
                let latitude = request.data["latitude"]?.string,
                let longitude = request.data["longitude"]?.string,
                let nameUser = request.data["nameUser"]?.string else {
                    print("bad Request")
                    throw Abort.badRequest
            }
            
            guard let id = request.parameters["id"]?.string else {
                throw Abort.custom(status: .badRequest, message: "Parameter nil")
            }
            
            let time = "\(NSDate().timeIntervalSince1970)"
            let object = Taklim(materi: materi, pemateri: pemateri, note: note, date: date, time: time, tempat: tempat, pamflet: pamflet, lokasi: Lokasi(latitude: latitude, longitude: longitude), createdAt: "\(NSDate())", updatedAt: "\(NSDate())", userId: id, nameUser: nameUser)
            if let taklimStore = TaklimStore.sharedInstance {
                try taklimStore.insert(taklim: object) { bool in
                    if bool {
                        print("post ok")
                        json = Response(status: .ok)
                    } else {
                        print("post gagal")
                        json = Response(status: .notImplemented)
                    }
                }
            }
            return json
        }
        
        taklim.get("/:id") { request in
            guard let id = request.parameters["id"]?.string else {
                throw Abort.badRequest
            }
            var t: [Taklim]!
            if let taklimStore = TaklimStore.sharedInstance {
                if let getById = taklimStore.getById(id: id) {
                    t = getById
                }
            }
            return try JSON(t.map { try $0.makeJSON()} )
        }
        
        taklim.delete("/delete/:id") { request in
            var r: Response!
            guard let id = request.parameters["id"]?.string else {
                throw Abort.badRequest
            }
            
            if let taklimStore = TaklimStore.sharedInstance {
                taklimStore.delete(id: id, completion: { (bool) in
                    if bool {
                        print("delete")
                        r = Response(status: .ok)
                    } else {
                        print("no delete")
                        r = Response(status:. notImplemented)
                    }
                })
            }
            return r
        }
        
        /* ------------ USER ------------ */
        
        user.post("register") { request in
            var json: Response!
            guard let firstName = request.data["firstName"]?.string,
                let lastName = request.data["lastName"]?.string,
                let email = request.data["email"]?.string,
                let password = request.data["password"]?.string,
                let avatar = request.data["avatar"]?.string else {
                    throw Abort.badRequest
            }
            
            let passwordHash = try drop.hash.make(password)
            let date = "\(NSDate())"
            let o = User(firstName: firstName, lastName: lastName, email: email, password: passwordHash, avatar: avatar, createdAt: date, updatedAt: date)
            if let userStore = UserStore.sharedInstance {
                userStore.register(user: o, completion: { (bool) in
                    if bool {
                        print("Register Berhasil")
                        json = Response(status: .ok, headers: ["Content-Type": "application/json"])
                    } else {
                        print("Register Gagal")
                        json = Response(status: .notImplemented, headers: ["Content-Type": "application/json"])
                    }
                })
            }
            return json
        }
        
        user.get("email/:email") { request in
            var u: User!
            guard let emailParam = request.parameters["email"]?.string else {
                throw Abort.badRequest
            }
            if let userStore = UserStore.sharedInstance {
                if let o = userStore.getEmail(email: emailParam) {
                    u = o
                } else {
                    return Response(status: .noContent)
                }
            }
            return try u.makeJSON()
        }
        
        user.get("login/:email/:password") { request in
            var json: Response?
            guard let email = request.parameters["email"]?.string, let password = request.parameters["password"]?.string else {
                throw Abort.badRequest
            }
            print(email)
            if let userStore = UserStore.sharedInstance {
                try userStore.login(email: email, password: password, completion: { (bool, user) in
                    if bool {
                        let u = try user!.makeJSON()
                        print("Login Berhasil")
                        json = try Response(status: .ok, json: u)
                    } else {
                        print("Login Gagal")
                        json = Response(status: .notImplemented, headers: ["Content-Type" : "application/json"])
                    }
                })
            }
            return json!
        }
    }
}
