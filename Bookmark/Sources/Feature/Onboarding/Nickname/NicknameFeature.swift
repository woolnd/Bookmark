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
        var isSaving = false
    }
    
    enum Action: Equatable {
        case nicknameChanged(String)
        case suggestionTapped(String)
        case doneTapped
        case saveCompleted(Result<Bool, NicknameError>)
    }
    
    enum NicknameError: Error, Equatable {
        case saveFailed
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
                state.isSaving = true
                let uid = state.uid
                let nickname = state.nickname.trimmingCharacters(in: .whitespaces)
                return .run { send in
                    do {
                        try await Firestore.firestore()
                            .collection("users")
                            .document(uid)
                            .setData([
                                "nickname": nickname,
                                "createdAt": FieldValue.serverTimestamp()
                            ], merge: true)
                        await send(.saveCompleted(.success(true)))
                    } catch {
                        await send(.saveCompleted(.failure(.saveFailed)))
                    }
                }
                
            case .saveCompleted(.success):
                state.isSaving = false
                return .none
                
            case .saveCompleted(.failure):
                state.isSaving = false
                return .none
            }
        }
    }
}
