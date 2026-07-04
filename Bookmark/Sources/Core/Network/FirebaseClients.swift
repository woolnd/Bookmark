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

// MARK: - 책 저장/조회/업데이트 + 독서 로그

struct BookStoreClient {
    var saveBook: @Sendable (String, Book) async throws -> Void
    var fetchBooks: @Sendable (String) async throws -> [Book]
    var updateBook: @Sendable (String, Book) async throws -> Void
    var deleteBook: @Sendable (String, String) async throws -> Void
    var saveLog: @Sendable (String, String, ReadingLog) async throws -> Void
    var fetchLogs: @Sendable (String, String) async throws -> [ReadingLog]
    var saveFinishedBook: @Sendable (String, FinishedBook) async throws -> Void
    var fetchFinishedBooks: @Sendable (String) async throws -> [FinishedBook]
}

extension BookStoreClient: DependencyKey {
    static let liveValue = BookStoreClient(
        saveBook: { uid, book in
            try await withCheckedThrowingContinuation { continuation in
                do {
                    try Firestore.firestore()
                        .collection("users")
                        .document(uid)
                        .collection("books")
                        .document(book.id)
                        .setData(from: book) { error in
                            if let error {
                                continuation.resume(throwing: error)
                            } else {
                                continuation.resume()
                            }
                        }
                } catch {
                    continuation.resume(throwing: error)
                }
            }
        },
        fetchBooks: { uid in
            try await withCheckedThrowingContinuation { continuation in
                Firestore.firestore()
                    .collection("users")
                    .document(uid)
                    .collection("books")
                    .getDocuments { snapshot, error in
                        if let error {
                            continuation.resume(throwing: error)
                            return
                        }
                        let books = snapshot?.documents.compactMap {
                            try? $0.data(as: Book.self)
                        } ?? []
                        continuation.resume(returning: books)
                    }
            }
        },
        updateBook: { uid, book in
            try await withCheckedThrowingContinuation { continuation in
                do {
                    try Firestore.firestore()
                        .collection("users")
                        .document(uid)
                        .collection("books")
                        .document(book.id)
                        .setData(from: book, merge: true) { error in
                            if let error {
                                continuation.resume(throwing: error)
                            } else {
                                continuation.resume()
                            }
                        }
                } catch {
                    continuation.resume(throwing: error)
                }
            }
        },
        deleteBook: { uid, bookId in
            try await withCheckedThrowingContinuation { continuation in
                Firestore.firestore()
                    .collection("users")
                    .document(uid)
                    .collection("books")
                    .document(bookId)
                    .delete { error in
                        if let error {
                            continuation.resume(throwing: error)
                        } else {
                            continuation.resume()
                        }
                    }
            }
        },
        saveLog: { uid, bookId, log in
            try await withCheckedThrowingContinuation { continuation in
                do {
                    try Firestore.firestore()
                        .collection("users")
                        .document(uid)
                        .collection("books")
                        .document(bookId)
                        .collection("logs")
                        .document(log.id)
                        .setData(from: log) { error in
                            if let error {
                                continuation.resume(throwing: error)
                            } else {
                                continuation.resume()
                            }
                        }
                } catch {
                    continuation.resume(throwing: error)
                }
            }
        },
        fetchLogs: { uid, bookId in
            try await withCheckedThrowingContinuation { continuation in
                Firestore.firestore()
                    .collection("users")
                    .document(uid)
                    .collection("books")
                    .document(bookId)
                    .collection("logs")
                    .order(by: "date", descending: true)
                    .getDocuments { snapshot, error in
                        if let error {
                            continuation.resume(throwing: error)
                            return
                        }
                        let logs = snapshot?.documents.compactMap {
                            try? $0.data(as: ReadingLog.self)
                        } ?? []
                        continuation.resume(returning: logs)
                    }
            }
        },
        saveFinishedBook: { uid, finishedBook in
            try await withCheckedThrowingContinuation { continuation in
                do {
                    try Firestore.firestore()
                        .collection("users")
                        .document(uid)
                        .collection("finishedBooks")
                        .document(finishedBook.id.uuidString)
                        .setData(from: finishedBook) { error in
                            if let error {
                                continuation.resume(throwing: error)
                            } else {
                                continuation.resume()
                            }
                        }
                } catch {
                    continuation.resume(throwing: error)
                }
            }
        },
        fetchFinishedBooks: { uid in
            try await withCheckedThrowingContinuation { continuation in
                Firestore.firestore()
                    .collection("users")
                    .document(uid)
                    .collection("finishedBooks")
                    .getDocuments { snapshot, error in
                        if let error {
                            continuation.resume(throwing: error)
                            return
                        }
                        let books = snapshot?.documents.compactMap {
                            try? $0.data(as: FinishedBook.self)
                        } ?? []
                        continuation.resume(returning: books)
                    }
            }
        }
    )

    static let testValue = BookStoreClient(
        saveBook: { _, _ in },
        fetchBooks: { _ in [] },
        updateBook: { _, _ in },
        deleteBook: { _, _ in },
        saveLog: { _, _, _ in },
        fetchLogs: { _, _ in [] },
        saveFinishedBook: { _, _ in },
        fetchFinishedBooks: { _ in [] }
    )
}

extension DependencyValues {
    var bookStoreClient: BookStoreClient {
        get { self[BookStoreClient.self] }
        set { self[BookStoreClient.self] = newValue }
    }
}
