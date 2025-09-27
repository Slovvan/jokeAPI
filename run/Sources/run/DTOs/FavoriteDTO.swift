import Fluent
import Vapor

struct FavoriteDTO: Content {
    var id: UUID?
    var user: UUID?
    var blague: UUID?
    var isLiked: Bool?
    
    func toModel() -> Favorite {
        let model = Favorite()
        
        model.id = self.id
        if let isLiked = self.isLiked {
            model.isLiked = isLiked
        }
        if let userId = self.user {
            model.$user.id = userId
        }
        if let blagueId = self.blague {
            model.$blague.id = blagueId
        }
        return model
    }
}
