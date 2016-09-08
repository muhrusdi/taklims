import Vapor
import HTTP

let drop = Droplet()
let mainCollection = MainCollection()

drop.collection(mainCollection)

drop.serve()
