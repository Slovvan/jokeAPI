import Vapor

struct JokeAPIResponse: Content {
    let error: Bool
    let category: String
    let type: String
    let setup: String?
    let delivery: String?
    let flags: Flags
    let safe: Bool
    let id: Int
    let lang: String

    struct Flags: Content {
        let nsfw: Bool
        let religious: Bool
        let political: Bool
        let racist: Bool
        let sexist: Bool
        let explicit: Bool
    }
}

struct CustomJokeRequest: Content {
    var category: String?
    var type: String?
    var safe: Bool?
    var lang: String?
    var flags: FlagsQuery?
}

struct FlagsQuery: Content {
    var nsfw: Bool?
    var religious: Bool?
    var political: Bool?
    var racist: Bool?
    var sexist: Bool?
    var explicit: Bool?
}
