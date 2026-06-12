import SwiftUI
import ComposableArchitecture

public struct ContentView: View {
    @Bindable var store: StoreOf<AppFeature>

    public var body: some View {
        SplashView(
            store: store.scope(
                state: \.onboarding.splash,
                action: \.onboarding.splash
            )
        )
        .background(Color.paper)
        .ignoresSafeArea()
    }
}
