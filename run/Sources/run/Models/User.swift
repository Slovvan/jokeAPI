import Fluent
import struct Foundation.UUID

/// Property wrappers interact poorly with `Sendable` checking, causing a warning for the `@ID` property
/// It is recommended you write your model with sendability checking on and then suppress the warning
/// afterwards with `@unchecked Sendable`.

final class User: Model, @unchecked Sendable {
    static let schema = "users"  // Nom de la table
    
    @ID(key: .id)               // Clé primaire UUID
    var id: UUID?

    @Field(key: "name")        // Champ titre
    var name: String
    
    @Field(key: "email")        // Champ titre
    var email: String
    
    @Field(key: "password") // Statut de completion
    var password: String

    @Field(key: "rol") // Statut de completion
    var rol: String
    
}

extension User {
    func toDTO() -> UserDTO {
        .init(
            id: self.id,
            name: self.$name.value,
            email: self.$email.value,
            password: self.$password.value,
            rol: self.$rol.value
        )
    }
}