import Fluent
import Vapor

func routes(_ app: Application) throws {
    app.get { req async throws in
        try await req.view.render("index", ["title": "Hello Vapor!"])
    }

    app.get("hello") { req async -> String in
        "Hello, world!"
    }

    let api = app.grouped("api")
    try api.register(collection: UserController())
    try api.register(collection: BlagueController())
    try api.register(collection: FavoriteController())

    try app.register(collection: TodoController())
      // Controlador de usuarios
    try app.register(collection: UserController())

    // Controlador de blagues
    try app.register(collection: BlagueController())

    // Controlador de favoritos
    try app.register(collection: FavoriteController())

    try app.register(collection: JokeAPIController())
}
