import SwiftUI
import FirebaseCore
import ComposableArchitecture
import KakaoSDKCommon

@main
struct BookmarkApp: App {
    
    init() {
        FirebaseApp.configure()
        KakaoSDK.initSDK(appKey: KakaoConfig.nativeAppKey)
        configureNavigationBarAppearance()
        configureTabBarAppearance()
    }
    
    static let store = Store(initialState: AppFeature.State.onboarding()) {
        AppFeature()
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView(store: Self.store)
                .preferredColorScheme(.light)
        }
    }
    
    private func configureNavigationBarAppearance() {
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor(Color.paper) 
        appearance.shadowColor = .clear
        
        appearance.largeTitleTextAttributes = [
            .font: UIFont(name: "Gaegu-Bold", size: 34) ?? .systemFont(ofSize: 34, weight: .bold),
            .foregroundColor: UIColor(Color.ink)
        ]
        appearance.titleTextAttributes = [
            .font: UIFont(name: "Gaegu-Bold", size: 18) ?? .systemFont(ofSize: 18, weight: .bold),
            .foregroundColor: UIColor(Color.ink)
        ]
        UINavigationBar.appearance().standardAppearance = appearance
        UINavigationBar.appearance().scrollEdgeAppearance = appearance
    }
    
    private func configureTabBarAppearance() {
        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor(Color.paper)
        
        UITabBar.appearance().standardAppearance = appearance
        UITabBar.appearance().scrollEdgeAppearance = appearance
    }
}
