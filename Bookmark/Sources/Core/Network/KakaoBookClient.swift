//
//  KakaoBookClient.swift
//  Bookmark-Dev
//
//  Created by wodnd on 6/16/26.
//

import Foundation
import ComposableArchitecture

struct KakaoBookClient {
    var search: @Sendable (String) async throws -> [KakaoBookResult]
}

extension KakaoBookClient: DependencyKey {
    static let liveValue = KakaoBookClient(
        search: { query in
            var componets = URLComponents(string: "https://dapi.kakao.com/v3/search/book")!
            componets.queryItems = [
                URLQueryItem(name: "query", value: query),
                URLQueryItem(name: "size", value: "20")
            ]
            
            var request = URLRequest(url: componets.url!)
            request.setValue("KakaoAK \(KakaoConfig.apiKey)", forHTTPHeaderField: "Authorization")
            
            let (data, response) = try await URLSession.shared.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse,
                  200..<300
                    ~= httpResponse.statusCode else {
                throw KakaoBookClientError.requestFailed
            }
            
            let decoded = try JSONDecoder().decode(KakaoBookSearchResponse.self, from: data)
            return decoded.documents
        }
    )
}

extension DependencyValues {
    var kakaoBookClient: KakaoBookClient {
        get { self[KakaoBookClient.self] }
        set { self[KakaoBookClient.self] = newValue }
    }
}

enum KakaoBookClientError: Error {
    case requestFailed
}

enum KakaoConfig {
    static var apiKey: String {
        guard let key = Bundle.main.object(forInfoDictionaryKey: "KAKAO_API_KEY") as? String else {
            fatalError("KAKAO_API_KEY가 Info.plist에 설정되지 않았어요")
        }
        return key
    }
}
