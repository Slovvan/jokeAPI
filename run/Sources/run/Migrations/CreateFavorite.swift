import Fluent

struct CreateFavorite: AsyncMigration {
    func prepare(on database: any Database) async throws {
        try await database.schema("favorites")
            .id()
            .field("user_id", .uuid, .required, .references("users", "id", onDelete: .cascade))
            .field("blague_id", .uuid, .required, .references("blagues", "id", onDelete: .cascade))
            .field("is_liked", .bool, .required)
            .create()
    }

    func revert(on database: any Database) async throws {
        try await database.schema("favorites").delete()
    }
    
}

