//
//  AppIntroFeature.swift
//  Bookmark-Dev
//
//  Created by wodnd on 6/12/26.
//

import Foundation
import ComposableArchitecture

@Reducer
struct AppIntroFeature {
    @ObservableState
    struct State: Equatable {}
    
    enum Action {
        case startTapped
    }
    
    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .startTapped:
                return .none
            }
        }
    }
}
