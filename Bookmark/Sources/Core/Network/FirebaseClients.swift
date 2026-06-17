//
//  FirebaseClients.swift
//  Bookmark
//
//  Created by wodnd on 6/17/26.
//

import Foundation
import ComposableArchitecture
import FirebaseAuth
import FirebaseFirestore

// MARK: - 인증 상태 확인

struct AuthClient {
    var currentUserId: @Sendable () -> String?
}

extension AuthClient: DependencyKey {
    static let liveValue = AuthClient(
        currentUserId: {
            Auth.auth().currentUser?.uid
        }
    )
    
    static let testValue = AuthClient(
        currentUserId: { nil }
    )
}

extension DependencyValues {
    var authClient: AuthClient {
        get { self[AuthClient.self] }
        set { self[AuthClient.self] = newValue }
    }
}

// MARK: - 유저 문서 (닉네임) 확인

struct UserClient {
    var hasNickname: @Sendable (String) async throws -> Bool
}

extension UserClient: DependencyKey {
    static let liveValue = UserClient(
        hasNickname: { uid in
            try await withCheckedThrowingContinuation { continuation in
                Firestore.firestore()
                    .collection("users")
                    .document(uid)
                    .getDocument { snapshot, error in
                        if let error {
                            continuation.resume(throwing: error)
                            return
                        }
                        
                        guard let snapshot, snapshot.exists else {
                            continuation.resume(returning: false)
                            return
                        }
                        
                        let nickname = snapshot.data()?["nickname"] as? String
                        continuation.resume(returning: nickname?.isEmpty == false)
                    }
            }
        }
    )
    
    static let testValue = UserClient(
        hasNickname: { _ in false }
    )
}

extension DependencyValues {
    var userClient: UserClient {
        get { self[UserClient.self] }
        set { self[UserClient.self] = newValue }
    }
}
