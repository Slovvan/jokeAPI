import Fluent
import Vapor

struct BlagueController: RouteCollection {
    func boot(routes: any RoutesBuilder) throws {
        let blagues = routes.grouped("blagues")

        blagues.get(use: self.index)
        blagues.post(use: self.create)
        blagues.group(":blagueID") { blague in
            blague.put(use: self.update)
            blague.delete(use: self.delete)
        }
    }

    // GET /blagues
    @Sendable
    func index(req: Request) async throws -> [BlagueDTO] {
        try await Blague.query(on: req.db)
            .with(\.$user) // carga la relación con usuario
            .all()
            .map { $0.toDTO() }
    }

    // POST /blagues
    @Sendable
    func create(req: Request) async throws -> BlagueDTO {
        let dto = try req.content.decode(BlagueDTO.self)
        let blague = dto.toModel()
        try await blague.save(on: req.db)
        return blague.toDTO()
    }

    // PUT /blagues/:blagueID
    @Sendable
    func update(req: Request) async throws -> BlagueDTO {
        guard let id = req.parameters.get("blagueID", as: UUID.self),
              let blague = try await Blague.find(id, on: req.db) else {
            throw Abort(.notFound)
        }

        let dto = try req.content.decode(BlagueDTO.self)

        blague.apiId = dto.apiId
        blague.category = dto.category
        blague.type = dto.type
        blague.setup = dto.setup
        blague.delivery = dto.delivery
        blague.safe = dto.safe
        blague.lang = dto.lang
        blague.nsfw = dto.nsfw
        blague.religious = dto.religious
        blague.political = dto.political
        blague.racist = dto.racist
        blague.sexist = dto.sexist
        blague.explicit = dto.explicit
        if let userId = dto.user {
            blague.$user.id = userId
        }

        try await blague.save(on: req.db)
        return blague.toDTO()
    }

    // DELETE /blagues/:blagueID
    @Sendable
    func delete(req: Request) async throws -> HTTPStatus {
        guard let id = req.parameters.get("blagueID", as: UUID.self),
              let blague = try await Blague.find(id, on: req.db) else {
            throw Abort(.notFound)
        }

        try await blague.delete(on: req.db)
        return .noContent
    }
}
