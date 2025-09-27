import Fluent
import Vapor
import struct Foundation.UUID

final class Blague: Model, @unchecked Sendable {
    static let schema = "blagues"
    
    @ID(key: .id)
    var id: UUID?

    @Field(key: "api_id")
    var apiId: Int
    
    @Field(key: "category")
    var category: String
    
    @Field(key: "type")
    var type: String
    
    @Field(key: "setup")
    var setup: String?
    
    @Field(key: "delivery")
    var delivery: String?
    
    @Field(key: "safe")
    var safe: Bool
    
    @Field(key: "lang")
    var lang: String
    
    @Field(key: "nsfw")
    var nsfw: Bool
    
    @Field(key: "religious")
    var religious: Bool
    
    @Field(key: "political")
    var political: Bool
    
    @Field(key: "racist")
    var racist: Bool
    
    @Field(key: "sexist")
    var sexist: Bool
    
    @Field(key: "explicit")
    var explicit: Bool

    @OptionalParent(key: "user_id")
    var user: User?
}

extension Blague {
    func toDTO() -> BlagueDTO {
        .init(
            id: self.id,
            apiId: self.apiId,
            category: self.category,
            type: self.type,
            setup: self.setup,
            delivery: self.delivery,
            safe: self.safe,
            lang: self.lang,
            nsfw: self.nsfw,
            religious: self.religious,
            political: self.political,
            racist: self.racist,
            sexist: self.sexist,
            explicit: self.explicit,
            user: self.$user.id
        )
    }
}
