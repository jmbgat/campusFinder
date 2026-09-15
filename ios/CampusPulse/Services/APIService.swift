import Foundation

enum APIError: LocalizedError {
    case invalidResponse
    case httpStatus(Int, String)
    case decoding(Error)
    case transport(Error)

    var errorDescription: String? {
        switch self {
        case .invalidResponse:
            "Unable to load events. Check your connection and try again."
        case .httpStatus(let code, let body):
            if code >= 500 {
                "The server had a problem (\(code)). Try again in a moment."
            } else if !body.isEmpty {
                body
            } else {
                "Request failed (\(code))."
            }
        case .decoding:
            "The server sent data this app version could not read."
        case .transport:
            "Unable to load events. Check your connection and try again."
        }
    }
}

struct APIService {
    var baseURL: URL = APIConfig.baseURL
    var session: URLSession = {
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 30
        config.timeoutIntervalForResource = 30
        return URLSession(configuration: config)
    }()

    func health() async throws -> Bool {
        let (data, response) = try await send(path: "/health")
        _ = data
        return (response as? HTTPURLResponse)?.statusCode == 200
    }

    func fetchEvents(
        category: EventCategory? = nil,
        accessType: AccessType? = nil,
        latitude: Double? = nil,
        longitude: Double? = nil
    ) async throws -> [CampusEvent] {
        var items: [URLQueryItem] = []
        if let category { items.append(.init(name: "category", value: category.rawValue)) }
        if let accessType { items.append(.init(name: "accessType", value: accessType.rawValue)) }
        if let latitude, let longitude {
            items.append(.init(name: "lat", value: String(latitude)))
            items.append(.init(name: "lon", value: String(longitude)))
            items.append(.init(name: "sort", value: "closest"))
        } else {
            items.append(.init(name: "sort", value: "soonest"))
        }
        let (data, _) = try await send(path: "/events", query: items)
        do {
            return try APIJSON.decoder.decode([CampusEvent].self, from: data)
        } catch {
            throw APIError.decoding(error)
        }
    }

    func fetchEvent(id: String) async throws -> CampusEvent {
        let (data, _) = try await send(path: "/events/\(id)")
        do {
            return try APIJSON.decoder.decode(CampusEvent.self, from: data)
        } catch {
            throw APIError.decoding(error)
        }
    }

    func createEvent(_ draft: EventDraft) async throws -> CampusEvent {
        let body = try APIJSON.encoder.encode(draft)
        let (data, _) = try await send(path: "/events", method: "POST", body: body)
        do {
            return try APIJSON.decoder.decode(CampusEvent.self, from: data)
        } catch {
            throw APIError.decoding(error)
        }
    }

    func logActivity(eventType: String, eventId: String? = nil, extra: [String: String] = [:]) async {
        struct Payload: Encodable {
            var eventType: String
            var eventId: String?
            var timestamp: Date
            var metadata: [String: String]?
        }
        let payload = Payload(
            eventType: eventType,
            eventId: eventId,
            timestamp: Date(),
            metadata: extra.isEmpty ? nil : extra
        )
        guard let body = try? APIJSON.encoder.encode(payload) else { return }
        _ = try? await send(path: "/activity", method: "POST", body: body)
    }

    private func send(
        path: String,
        method: String = "GET",
        query: [URLQueryItem] = [],
        body: Data? = nil
    ) async throws -> (Data, URLResponse) {
        var components = URLComponents(url: baseURL.appending(path: path.trimmingCharacters(in: CharacterSet(charactersIn: "/"))), resolvingAgainstBaseURL: false)
        if !query.isEmpty {
            components?.queryItems = query
        }
        guard let url = components?.url else { throw APIError.invalidResponse }
        var request = URLRequest(url: url)
        request.httpMethod = method
        request.timeoutInterval = 30
        if let body {
            request.httpBody = body
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        }
        do {
            let (data, response) = try await session.data(for: request)
            guard let http = response as? HTTPURLResponse else { throw APIError.invalidResponse }
            guard (200 ..< 300).contains(http.statusCode) else {
                let text = String(data: data, encoding: .utf8) ?? ""
                throw APIError.httpStatus(http.statusCode, prettyDetail(text))
            }
            return (data, response)
        } catch let error as APIError {
            throw error
        } catch {
            throw APIError.transport(error)
        }
    }

    private func prettyDetail(_ raw: String) -> String {
        guard let data = raw.data(using: .utf8),
              let obj = try? JSONSerialization.jsonObject(with: data)
        else { return raw }
        if let dict = obj as? [String: Any] {
            if let detail = dict["detail"] as? String { return detail }
            if let details = dict["detail"] as? [[String: Any]] {
                let messages = details.compactMap { $0["msg"] as? String }
                if !messages.isEmpty { return messages.joined(separator: " ") }
            }
        }
        return raw
    }
}
