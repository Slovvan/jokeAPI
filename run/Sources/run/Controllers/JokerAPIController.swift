import Vapor
import Fluent

struct JokeAPIController: RouteCollection {
    func boot(routes: any RoutesBuilder) throws {
        let jokes = routes.grouped("jokes")
        jokes.get("random", use: getRandomJoke)
        jokes.get("custom", use: getCustomJoke)
    }

    @Sendable
    func getRandomJoke(req: Request) async throws -> BlagueDTO {
        // Traer broma desde JokeAPI
        let url = "https://v2.jokeapi.dev/joke/Any?lang=fr"
    
        let response = try await req.client.get(URI(string: url))
        let jokeData = try response.content.decode(JokeAPIResponse.self)

        return try await saveOrFetch(jokeData, req: req)
    }
    

    // Nueva: acepta parámetros por query
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
            .filter(\.$apiId == jokeData.id)
            .first()
        {
            return existing.toDTO()
        }

        // Convertir a DTO (aplanando los flags)
        let blagueDTO = BlagueDTO(
            apiId: jokeData.id,
            category: jokeData.category,
            type: jokeData.type,
            setup: jokeData.setup,
            delivery: jokeData.delivery,
            safe: jokeData.safe,
            lang: jokeData.lang,
            nsfw: body.flags?.nsfw ?? jokeData.flags.nsfw,
            religious: body.flags?.religious ?? jokeData.flags.religious,
            political: body.flags?.political ?? jokeData.flags.political,
            racist: body.flags?.racist ?? jokeData.flags.racist,
            sexist: body.flags?.sexist ?? jokeData.flags.sexist,
            explicit: jokeData.flags.explicit,
            user: nil // Sin asignar a ningún usuario
        )

        // Guardar en la DB
        let blague = blagueDTO.toModel()
        try await blague.save(on: req.db)

        return blagueDTO
    }



}
