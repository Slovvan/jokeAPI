import Fluent
import struct Foundation.UUID

/// Property wrappers interact poorly with `Sendable` checking, causing a warning for the `@ID` property
/// It is recommended you write your model with sendability checking on and then suppress the warning
/// afterwards with `@unchecked Sendable`.

final class Favorite: Model, @unchecked Sendable {
    static let schema = "favorites"  // Nom de la table
    
    @ID(key: .id)               // Clé primaire UUID
    var id: UUID?
    
    @Parent(key: "user_id")        // Champ titre
    var user: User //Relation with the user model
    
    @Parent(key: "blague_id")        // Champ titre
    var blague: Blague //Relation with the blague model

    @Field(key: "is_liked") // Statut de completion
    var isLiked: Bool
}


extension Favorite {
    func toDTO() -> FavoriteDTO {
        .init(
            id: self.id,
            user: self.$user.id,
            blague: self.$blague.id,
            isLiked: self.$isLiked.value
        )
    }
}
