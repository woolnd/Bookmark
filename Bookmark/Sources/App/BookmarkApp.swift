import SwiftUI
import FirebaseCore
import ComposableArchitecture
import KakaoSDKCommon

@main
struct BookmarkApp: App {
    
    init() {
        FirebaseApp.configure()
        KakaoSDK.initSDK(appKey: KakaoConfig.nativeAppKey)
    }
    
    static let store = Store(initialState: AppFeature.State.onboarding()) {
        AppFeature()
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView(store: Self.store)
        }
    }
}
