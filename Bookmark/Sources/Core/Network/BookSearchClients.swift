//
//  BookSearchClients.swift
//  Bookmark
//
//  Created by wodnd on 6/17/26.
//

import Foundation
import ComposableArchitecture
import UIKit

// MARK: - 카카오 책 검색

struct KakaoBookClient {
    var search: @Sendable (String) async throws -> [KakaoBookResult]
}

extension KakaoBookClient: DependencyKey {
    static let liveValue = KakaoBookClient(
        search: { query in
            var components = URLComponents(string: "https://dapi.kakao.com/v3/search/book")!
            components.queryItems = [
                URLQueryItem(name: "query", value: query),
                URLQueryItem(name: "size", value: "20")
            ]
            
            var request = URLRequest(url: components.url!)
            request.setValue("KakaoAK \(KakaoConfig.apiKey)", forHTTPHeaderField: "Authorization")
            request.setValue(KakaoConfig.kaHeader, forHTTPHeaderField: "KA")
            
            let (data, response) = try await URLSession.shared.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse,
                  200..<300 ~= httpResponse.statusCode else {
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
    
    static var nativeAppKey: String {
        guard let key = Bundle.main.object(forInfoDictionaryKey: "KAKAO_NATIVE_APP_KEY") as? String else {
            fatalError("KAKAO_NATIVE_APP_KEY가 Info.plist에 설정되지 않았어요")
        }
        return key
    }
    
    /// 카카오 REST API 호출 시 필요한 KA 헤더
    static var kaHeader: String {
        let bundleId = Bundle.main.bundleIdentifier ?? "com.wodnd.bookmark"
        return "sdk/2.23.0 os/ios-\(UIDevice.current.systemVersion) origin/\(bundleId)"
    }
}

// MARK: - 알라딘 책 조회 (페이지 수 보강)

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
            
            guard let item = decoded.item.first else {
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
