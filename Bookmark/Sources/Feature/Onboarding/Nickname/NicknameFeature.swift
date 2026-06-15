//
//  NicknameFeature.swift
//  Bookmark-Dev
//
//  Created by wodnd on 6/13/26.
//

import Foundation
import ComposableArchitecture
import FirebaseFirestore

@Reducer
struct NicknameFeature {
    @ObservableState
    struct State: Equatable {
        var uid: String
        var nickname: String = ""
        var isLoading = false
        var toastMessage: String? = nil
    }
    
    enum Action: Equatable {
        case nicknameChanged(String)
        case suggestionTapped(String)
        case doneTapped
        case saveCompleted(Result<Bool, NicknameError>)
        case toastDismissed
    }
    
    enum NicknameError: Error, Equatable {
        case saveFailed
        case timeout
        case networkError
    }
    
    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .nicknameChanged(let value):
                state.nickname = String(value.prefix(12))
                return .none
                
            case .suggestionTapped(let value):
                state.nickname = value
                return .none
                
            case .doneTapped:
                guard NetworkMonitor.shared.isConnected else {
                    state.toastMessage = "네트워크 연결을 확인해주세요 "
                    return .none
                }
                
                state.isLoading = true
                let uid = state.uid
                let nickname = state.nickname.trimmingCharacters(in: .whitespaces)
                return .run { send in
                    do {
                        try await withTimeout(seconds: 10) {
                            try await Firestore.firestore()
                                .collection("users")
                                .document(uid)
                                .setData([
                                    "nickname": nickname,
                                    "createdAt": FieldValue.serverTimestamp()
                                ], merge: true)
                        }
                        await send(.saveCompleted(.success(true)))
                    } catch is CancellationError {
                        await send(.saveCompleted(.failure(.timeout)))
                    } catch {
                        let nsError = error as NSError
                        if nsError.code == NSURLErrorNotConnectedToInternet {
                            await send(.saveCompleted(.failure(.networkError)))
                        } else {
                            await send(.saveCompleted(.failure(.saveFailed)))
                        }
                    }
                }
                
            case .saveCompleted(.success):
                state.isLoading = false
                return .none
                
            case .saveCompleted(.failure(let error)):
                state.isLoading = false
                switch error {
                case .timeout:
                    state.toastMessage = "요청 시간이 초과됐어요. 다시 시도해주세요"
                case .networkError:
                    state.toastMessage = "네트워크 연결을 확인해주세요"
                case .saveFailed:
                    state.toastMessage = "저장에 실패했어요. 다시 시도해주세요"
                }
                return .none
                
            case .toastDismissed:
                state.toastMessage = nil
                return .none
            }
        }
    }
}
