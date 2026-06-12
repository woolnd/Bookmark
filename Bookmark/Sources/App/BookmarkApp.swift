import SwiftUI
import ComposableArchitecture

@main
struct BookmarkApp: App {
    
    static let store = Store(initialState: AppFeature.State()) {
        AppFeature()
    }
    var body: some Scene {
        WindowGroup {
            ContentView(store: Self.store)
        }
    }
}
