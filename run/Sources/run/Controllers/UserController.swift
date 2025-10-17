import Fluent
import Vapor

struct UserController: RouteCollection {
    func boot(routes: any RoutesBuilder) throws {
        let users = routes.grouped("users")

        users.get(use: self.index)
        users.post("login", use: self.login)
        users.post(use: self.create)
        users.group(":userID") { user in
            user.put(use: self.update)
            user.delete(use: self.delete)
        }
    }

    struct LoginRequest: Content {
    let email: String
    let password: String
}

    @Sendable
    func login(req: Request) async throws -> UserDTO {
        let loginData = try req.content.decode(LoginRequest.self)
        
        guard let user = try await User.query(on: req.db)
            .filter(\.$email == loginData.email)
            .first() else {
            throw Abort(.unauthorized, reason: "Email no encontrado")
        }
        
        if user.password != loginData.password {
            throw Abort(.unauthorized, reason: "Contraseña incorrecta")
        }
        
        return user.toDTO()
    }


    @Sendable
    func index(req: Request) async throws -> [UserDTO] {
        try await User.query(on: req.db).all().map { $0.toDTO() }
    }

    @Sendable
    func create(req: Request) async throws -> UserDTO {
        let user = try req.content.decode(UserDTO.self).toModel()
        try await user.save(on: req.db)
        return user.toDTO()
    }

    @Sendable
    func update(req: Request) async throws -> UserDTO {
        guard let id = req.parameters.get("userID", as: UUID.self),
              let user = try await User.find(id, on: req.db) else {
            throw Abort(.notFound)
        }

        let dto = try req.content.decode(UserDTO.self)
        if let name = dto.name { user.name = name }
        if let email = dto.email { user.email = email }
        if let password = dto.password { user.password = password }
        if let rol = dto.rol { user.rol = rol }

        try await user.save(on: req.db)
        return user.toDTO()
    }

    @Sendable
    func delete(req: Request) async throws -> HTTPStatus {
        guard let id = req.parameters.get("userID", as: UUID.self),
              let user = try await User.find(id, on: req.db) else {
            throw Abort(.notFound)
        }

        try await user.delete(on: req.db)
        return .noContent
    }
}
