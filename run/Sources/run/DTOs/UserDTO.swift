import Fluent
import Vapor

struct UserDTO: Content {
    var id: UUID?
    var name: String?
    var email: String?
    var password: String?
    var rol: String?
    
    func toModel() -> User {
        let model = User()
        
        model.id = self.id
        if let name = self.name {
            model.name = name
        }
        if let email = self.email {
            model.email = email
        }
        if let password = self.password {
            model.password = password
        }
        if let rol = self.rol {
            model.rol = rol
        }
        
        return model
    }
}
