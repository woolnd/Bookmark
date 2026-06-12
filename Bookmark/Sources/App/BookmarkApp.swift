import SwiftUI
import FirebaseCore
import ComposableArchitecture

@main
struct BookmarkApp: App {
    
    init() {
        FirebaseApp.configure()
    }
    
    static let store = Store(initialState: AppFeature.State()) {
        AppFeature()
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView(store: Self.store)
        }
    }
}
