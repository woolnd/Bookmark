//
//  HomeFeature.swift
//  Bookmark-Dev
//
//  Created by wodnd on 6/16/26.
//

import Foundation
import ComposableArchitecture

@Reducer
struct HomeFeature {
    @ObservableState
    struct State: Equatable {
        var books: [Book] = []
        var friends: [Friend] = []
        var showAll: Bool = false
        var selectedBook: Book? = nil
        var selectedFriend: Friend? = nil
        var sheetBook: Book? = nil
    }
    
    enum Action {
        case bookCardTapped(Book)
        case friendFeedTapped(Friend)
        case recordButtonTapped(Book)
        case showAllToggled
        case bookDetailDismissed
        case friendDetailDismissed
        case progressSheetDismissed
    }
    
    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .bookCardTapped(let book):
                state.selectedBook = book
                return .none
                
            case .friendFeedTapped(let friend):
                state.selectedFriend = friend
                return .none
                
            case .recordButtonTapped(let book):
                state.sheetBook = book
                return .none
                
            case .showAllToggled:
                state.showAll.toggle()
                return .none
                
            case .bookDetailDismissed:
                state.selectedBook = nil
                return .none
                
            case .friendDetailDismissed:
                state.selectedFriend = nil
                return .none
                
            case .progressSheetDismissed:
                state.sheetBook = nil
                return .none
            }
        }
    }
}
