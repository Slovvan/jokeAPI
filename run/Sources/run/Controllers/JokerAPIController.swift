import Vapor
import Fluent
import Foundation

struct JokeAPIController: RouteCollection {
    func boot(routes: any RoutesBuilder) throws {
        let jokes = routes.grouped("jokes")
        jokes.post("random", use: getRandomJoke)
        jokes.post("custom", use: getCustomJoke)
    }

    // MARK: - POST /jokes/random
    @Sendable
    func getRandomJoke(req: Request) async throws -> BlagueDTO {
        // Puedes permitir que el usuario opcionalmente envíe un idioma
        struct RandomJokeRequest: Content {
            var lang: String?
        }

        let body = try? req.content.decode(RandomJokeRequest.self)
        let lang = body?.lang ?? "fr"

        // Llamada al API externa
        let url = "https://v2.jokeapi.dev/joke/Any?lang=\(lang)"
        let response = try await req.client.get(URI(string: url))
        let jokeData = try response.content.decode(JokeAPIResponse.self)

        // Crear DTO
        let blagueDTO = BlagueDTO(
            id: nil,
            apiId: jokeData.id ?? 0,
            category: jokeData.category ?? "Misc",
            type: jokeData.type ??  (jokeData.joke != nil ? "single" : "twopart"),
            setup: jokeData.setup,
            delivery: jokeData.delivery,
            safe: jokeData.safe ?? false,
            lang: jokeData.lang ?? "en",
            nsfw: jokeData.flags?.nsfw ?? false,
            religious: jokeData.flags?.religious ?? false,
            political: jokeData.flags?.political ?? false,
            racist: jokeData.flags?.racist ?? false,
            sexist: jokeData.flags?.sexist ?? false,
            explicit: jokeData.flags?.explicit ?? false,
            user: nil
        )

        // Guardar en la base de datos
        let blague = blagueDTO.toModel()
        try await blague.save(on: req.db)

        return blagueDTO
    }

    // MARK: - POST /jokes/custom
      @Sendable
    func getCustomJoke(req: Request) async throws -> BlagueDTO {
        let body = try req.content.decode(CustomJokeRequest.self)
        
        let lang = body.lang ?? "fr"
        let type = body.type ?? "twopart"
        let category = (body.category?.isEmpty == false) ? body.category! : "Any"
        
        let flags = body.flags
        let blacklistFlags = [
            flags?.nsfw == true ? "nsfw" : nil,
            flags?.sexist == true ? "sexist" : nil,
            flags?.religious == true ? "religious" : nil,
            flags?.political == true ? "political" : nil,
            flags?.racist == true ? "racist" : nil,
            flags?.explicit == true ? "explicit" : nil
        ].compactMap { $0 }

        let blacklistQuery = blacklistFlags.isEmpty ? "" : "&blacklistFlags=" + blacklistFlags.joined(separator: ",")

        let url = "https://v2.jokeapi.dev/joke/\(category)?lang=\(lang)&type=\(type)\(blacklistQuery)"
  
        let response = try await req.client.get(URI(string: url))
        let jokeData = try response.content.decode(JokeAPIResponse.self)
    
            // 🔹 Imprimir en consola para depuración
            print("!!!!!!!!!!!!!!!!!!Respuesta cruda de JokeAPI!!!!!!!!!!!!!!!!!!!:", jokeData)

        return try await saveOrFetch(jokeData, req: req)
    }

    private func saveOrFetch(_ jokeData: JokeAPIResponse, req: Request) async throws -> BlagueDTO {
        let body = try req.content.decode(CustomJokeRequest.self)
        // Verificar si ya existe en la DB por apiId
        if let existing = try await Blague.query(on: req.db)
            .filter(\.$apiId == (jokeData.id ?? 0))
            .first()
        {
            return existing.toDTO()
        }

        // Convertir a DTO (aplanando los flags)
        let blagueDTO = BlagueDTO(
            apiId: jokeData.id ?? 0,
            category: jokeData.category ?? "Misc",
            type: jokeData.type ?? "single",
            setup: jokeData.setup ?? "",
            delivery: jokeData.delivery ?? jokeData.joke,
            safe: jokeData.safe ?? false,
            lang: jokeData.lang ?? "fr",
            nsfw: body.flags?.nsfw ?? jokeData.flags?.nsfw ?? false,
            religious: body.flags?.religious ?? jokeData.flags?.religious ?? false,
            political: body.flags?.political ?? jokeData.flags?.political ?? false,
            racist: body.flags?.racist ?? jokeData.flags?.racist ?? false,
            sexist: body.flags?.sexist ?? jokeData.flags?.sexist ?? false,
            explicit: jokeData.flags?.explicit ?? false,
            user: nil // Sin asignar a ningún usuario
        )

        // Guardar en la DB
        let blague = blagueDTO.toModel()
        try await blague.save(on: req.db)

        return blagueDTO
    }

}
