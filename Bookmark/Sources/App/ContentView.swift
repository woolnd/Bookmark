import SwiftUI
import ComposableArchitecture

public struct ContentView: View {
    @Bindable var store: StoreOf<AppFeature>

    public var body: some View {
        switch store.onboarding {
        case .splash:
            if let splashStore = store.scope(state: \.onboarding.splash, action: \.onboarding.splash) {
                SplashView(store: splashStore)
            }
            
        case .appIntro:
            if let introStore = store.scope(state: \.onboarding.appIntro, action: \.onboarding.appIntro) {
                AppIntroView(store: introStore)
            }
            
        case .login:
            if let loginStore = store.scope(state: \.onboarding.login, action: \.onboarding.login) {
                LoginView(store: loginStore)
            }
        }
    }
}
