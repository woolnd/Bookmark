//
//  ContentView.swift
//  Bookmark
//
//  Created by wodnd on 6/12/26.
//

import SwiftUI
import ComposableArchitecture

public struct ContentView: View {
    @Bindable var store: StoreOf<AppFeature>

    public var body: some View {
        switch store.state {
        case .onboarding:
            if let onboardingStore = store.scope(state: \.onboarding, action: \.onboarding) {
                OnboardingView(store: onboardingStore)
            }
        case .main:
            if let mainStore = store.scope(state: \.main, action: \.main) {
                MainTabView(store: mainStore)
            }
        }
    }
}
