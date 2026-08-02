import Foundation

struct AladinBookSearchResult: Identifiable, Hashable {
    let id: String // isbn13 (falls back to isbn10 if isbn13 is empty)
    let title: String
    let author: String
    let coverURLString: String?
    let pageCount: Int?
    let publisher: String?
}

enum AladinBookServiceError: Error {
    case missingAPIKey
    case invalidResponse
}

/// Searches book metadata via Aladin's Open API (알라딘 오픈API).
/// Requires a free TTBKey from https://www.aladin.co.kr/ttb/wblog_manager.aspx,
/// set as `AladinTTBKey` in Info.plist.
final class AladinBookService {
    static let shared = AladinBookService()

    private var apiKey: String? {
        Bundle.main.object(forInfoDictionaryKey: "AladinTTBKey") as? String
    }

    func search(query: String) async throws -> [AladinBookSearchResult] {
        guard let apiKey, !apiKey.isEmpty else {
            throw AladinBookServiceError.missingAPIKey
        }

        var components = URLComponents(string: "https://www.aladin.co.kr/ttb/api/ItemSearch.aspx")!
        components.queryItems = [
            URLQueryItem(name: "ttbkey", value: apiKey),
            URLQueryItem(name: "Query", value: query),
            URLQueryItem(name: "QueryType", value: "Title"),
            URLQueryItem(name: "MaxResults", value: "20"),
            URLQueryItem(name: "start", value: "1"),
            URLQueryItem(name: "SearchTarget", value: "Book"),
            URLQueryItem(name: "output", value: "js"),
            URLQueryItem(name: "Version", value: "20131101"),
        ]

        guard let url = components.url else { throw AladinBookServiceError.invalidResponse }

        let (data, _) = try await URLSession.shared.data(from: url)
        let decoded = try JSONDecoder().decode(AladinSearchResponse.self, from: data)

        return (decoded.item ?? []).map {
            AladinBookSearchResult(
                id: $0.isbn13.isEmpty ? $0.isbn : $0.isbn13,
                title: $0.title,
                author: $0.author,
                coverURLString: $0.cover,
                pageCount: $0.subInfo?.itemPage,
                publisher: $0.publisher
            )
        }
    }
}

private struct AladinSearchResponse: Decodable {
    let item: [AladinItem]?
}

private struct AladinItem: Decodable {
    let title: String
    let author: String
    let publisher: String?
    let cover: String?
    let isbn: String
    let isbn13: String
    let subInfo: AladinSubInfo?
}

private struct AladinSubInfo: Decodable {
    // NOTE: page-count availability from Aladin's API has not been verified
    // against a live call in this environment — double-check this field name
    // against the current Aladin API docs once you have a TTBKey.
    let itemPage: Int?
}
