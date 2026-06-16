//
//  AladinBookClient.swift
//  Bookmark-Dev
//
//  Created by wodnd on 6/16/26.
//

import Foundation
import ComposableArchitecture

struct AladinBookClient {
    var lookup: @Sendable (String) async throws -> AladinBookInfo
}

extension AladinBookClient: DependencyKey {
    static let liveValue = AladinBookClient(
        lookup: { isbn13 in
            var components = URLComponents(string: "http://www.aladin.co.kr/ttb/api/ItemLookUp.aspx")!
            components.queryItems = [
                URLQueryItem(name: "ttbkey", value: AladinConfig.ttbKey),
                URLQueryItem(name: "itemIdType", value: "ISBN13"),
                URLQueryItem(name: "ItemId", value: isbn13),
                URLQueryItem(name: "output", value: "js"),
                URLQueryItem(name: "Version", value: "20131101"),
                URLQueryItem(name: "OptResult", value: "subInfo")
            ]
            
            let (data, response) = try await URLSession.shared.data(from: components.url!)
            
            guard let httpResponse = response as? HTTPURLResponse,
                  200..<300 ~= httpResponse.statusCode else {
                throw AladinBookClientError.requestFailed
            }
            
            let decoded = try JSONDecoder().decode(AladinLookupResponse.self, from: data)
            
            guard let item = decoded.item.first else  {
                throw AladinBookClientError.notFound
            }
            
            return item
        }
    )
}

extension DependencyValues {
    var aladinBookClient: AladinBookClient {
        get { self[AladinBookClient.self] }
        set { self[AladinBookClient.self] = newValue }
    }
}

enum AladinBookClientError: Error {
    case requestFailed
    case notFound
}

enum AladinConfig {
    static var ttbKey: String {
        guard let key = Bundle.main.object(forInfoDictionaryKey: "ALADIN_TTB_KEY") as? String else {
            fatalError("ALADIN_TTB_KEY가 Info.plist에 설정되지 않았어요")
        }
        return key
    }
}
