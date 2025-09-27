import Fluent
import Vapor

struct FavoriteController: RouteCollection {
    func boot(routes: any RoutesBuilder) throws {
        let favorites = routes.grouped("favorites")

        favorites.get("user", ":userID", use: self.favoritesByUser)
        //favorites.get(use: self.index)
        favorites.post(use: self.create)
        favorites.group(":favoriteID") { favorite in
            favorite.put(use: self.update)
            favorite.delete(use: self.delete)
        }
    }

    @Sendable
    func favoritesByUser(req: Request) async throws -> [FavoriteDTO] {
    guard let userID = req.parameters.get("userID", as: UUID.self) else {
        throw Abort(.badRequest, reason: "Missing userID")
    }

    return try await Favorite.query(on: req.db)
        .filter(\.$user.$id == userID)
        .with(\.$user)
        .all()
        .map { $0.toDTO() }
    }

    @Sendable
    func index(req: Request) async throws -> [FavoriteDTO] {
        try await Favorite.query(on: req.db)
            .with(\.$user)
            .all()
            .map { $0.toDTO() }
    }

    @Sendable
    func create(req: Request) async throws -> FavoriteDTO {
        let favorite = try req.content.decode(FavoriteDTO.self).toModel()
        try await favorite.save(on: req.db)
        return favorite.toDTO()
    }

    @Sendable
    func update(req: Request) async throws -> FavoriteDTO {
        guard let id = req.parameters.get("favoriteID", as: UUID.self),
              let favorite = try await Favorite.find(id, on: req.db) else {
            throw Abort(.notFound)
        }

        let dto = try req.content.decode(FavoriteDTO.self)
        if let isLiked = dto.isLiked { favorite.isLiked = isLiked }
        if let userId = dto.user { favorite.$user.id = userId }

        try await favorite.save(on: req.db)
        return favorite.toDTO()
    }

    @Sendable
    func delete(req: Request) async throws -> HTTPStatus {
        guard let id = req.parameters.get("favoriteID", as: UUID.self),
              let favorite = try await Favorite.find(id, on: req.db) else {
            throw Abort(.notFound)
        }

        try await favorite.delete(on: req.db)
        return .noContent
    }
}
