//
//  BookDetailFeature.swift
//  Bookmark
//
//  Created by wodnd on 7/5/26.
//

import Foundation
import ComposableArchitecture

@Reducer
struct BookDetailFeature {
    @ObservableState
    struct State: Equatable {
        var book: Book
        var logs: [ReadingLog] = []
        var isLoadingLogs: Bool = false
        
        var isProgressSheetPresented: Bool = false
        var inputMemo: String = ""
        
        var isFinishedSheetPresented: Bool = false
        var finishedMemo: String = ""
    }
    
    enum Action: BindableAction {
        case binding(BindingAction<State>)
        case onAppear
        case logsLoaded([ReadingLog])
        case progressSheetPresented
        case progressSheetDismissed
        case updatePageConfirmed(Int)   // page를 직접 받음
        case pageUpdated(Book)
        case finishedSheetDismissed
        case finishedConfirmed
        case bookFinished(Book)
        case restartBook
        case dismiss
    }
    
    @Dependency(\.bookStoreClient) var bookStoreClient
    @Dependency(\.dismiss) var dismiss
    
    var body: some ReducerOf<Self> {
        BindingReducer()
        Reduce { state, action in
            switch action {
            case .onAppear:
                state.isLoadingLogs = true
                let bookId = state.book.id
                let uid = state.book.uid
                return .run { send in
                    let logs = try await bookStoreClient.fetchLogs(uid, bookId)
                    await send(.logsLoaded(logs))
                }
                
            case .logsLoaded(let logs):
                state.isLoadingLogs = false
                state.logs = logs
                return .none
                
            case .progressSheetPresented:
                state.inputMemo = ""
                state.isProgressSheetPresented = true
                return .none
                
            case .progressSheetDismissed:
                state.isProgressSheetPresented = false
                state.inputMemo = ""
                return .none
                
            case .updatePageConfirmed(let newPage):
                guard newPage > state.book.currentPage,
                      newPage <= state.book.totalPages else {
                    return .none
                }
                
                let fromPage = state.book.currentPage
                let memo = state.inputMemo
                let uid = state.book.uid
                
                state.book.currentPage = newPage
                state.isProgressSheetPresented = false
                
                if newPage >= state.book.totalPages {
                    state.isFinishedSheetPresented = true
                }
                
                let book = state.book
                let log = ReadingLog(
                    bookId: book.id,
                    date: Date(),
                    fromPage: fromPage,
                    toPage: newPage,
                    memo: memo,
                    type: newPage >= book.totalPages ? .finished : .progress
                )
                state.logs.insert(log, at: 0)
                
                return .run { send in
                    try await bookStoreClient.updateBook(uid, book)
                    try await bookStoreClient.saveLog(uid, book.id, log)
                    await send(.pageUpdated(book))
                }
                
            case .pageUpdated:
                return .none
                
            case .finishedSheetDismissed:
                state.isFinishedSheetPresented = false
                state.finishedMemo = ""
                return .none
                
            case .finishedConfirmed:
                let uid = state.book.uid
                let bookId = state.book.id
                let memo = state.finishedMemo
                state.isFinishedSheetPresented = false
                state.book.currentPage = state.book.totalPages
                
                let log = ReadingLog(
                    bookId: bookId,
                    date: Date(),
                    fromPage: state.book.currentPage,
                    toPage: state.book.totalPages,
                    memo: memo,
                    type: .finished
                )
                state.logs.insert(log, at: 0)
                
                let book = state.book
                return .run { send in
                    try await bookStoreClient.saveLog(uid, bookId, log)
                    await send(.bookFinished(book))
                }
                
            case .bookFinished:
                return .none
                
            case .restartBook:
                state.book.currentPage = 0
                let uid = state.book.uid
                let book = state.book
                return .run { _ in
                    try await bookStoreClient.updateBook(uid, book)
                }
                
            case .dismiss:
                return .run { _ in await dismiss() }
                
            case .binding:
                return .none
            }
        }
    }
}
