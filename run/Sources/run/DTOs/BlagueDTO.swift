import Fluent
import Vapor
import struct Foundation.UUID

struct BlagueDTO: Content {
    var id: UUID?
    var apiId: Int
    var category: String
    var type: String
    var setup: String?
    var delivery: String?
    var safe: Bool
    var lang: String
    var nsfw: Bool
    var religious: Bool
    var political: Bool
    var racist: Bool
    var sexist: Bool
    var explicit: Bool
    var user: UUID?

    func toModel() -> Blague {
        let model = Blague()
        model.id = self.id
        model.apiId = self.apiId
        model.category = self.category
        model.type = self.type
        model.setup = self.setup
        model.delivery = self.delivery
        model.safe = self.safe
        model.lang = self.lang
        model.nsfw = self.nsfw
        model.religious = self.religious
        model.political = self.political
        model.racist = self.racist
        model.sexist = self.sexist
        model.explicit = self.explicit
        if let userId = self.user {
            model.$user.id = userId
        }
        return model
    }
}
