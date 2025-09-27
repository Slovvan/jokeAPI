import Fluent

struct CreateBlague: AsyncMigration {
    func prepare(on database: any Database) async throws {
        try await database.schema("blagues")
            .id()
            .field("api_id", .int, .required)
            .field("category", .string, .required)
            .field("type", .string, .required)
            .field("setup", .string)
            .field("delivery", .string)
            .field("safe", .bool, .required)
            .field("lang", .string, .required)
            .field("nsfw", .bool, .required)
            .field("religious", .bool, .required)
            .field("political", .bool, .required)
            .field("racist", .bool, .required)
            .field("sexist", .bool, .required)
            .field("explicit", .bool, .required)
            .field("user_id", .uuid, .references("users", "id", onDelete: .cascade))
            .create()
    }

    func revert(on database: any Database) async throws {
        try await database.schema("blagues").delete()
    }
}
