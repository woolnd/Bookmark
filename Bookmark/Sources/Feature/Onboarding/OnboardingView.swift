//
//  OnboardingView.swift
//  Bookmark-Dev
//
//  Created by wodnd on 6/16/26.
//

import SwiftUI
import ComposableArchitecture

struct OnboardingView: View {
    @Bindable var store: StoreOf<OnboardingFeature>

    var body: some View {
        switch store.state {
        case .splash:
            if let s = store.scope(state: \.splash, action: \.splash) {
                SplashView(store: s)
            }
        case .appIntro:
            if let s = store.scope(state: \.appIntro, action: \.appIntro) {
                AppIntroView(store: s)
            }
        case .login:
            if let s = store.scope(state: \.login, action: \.login) {
                LoginView(store: s)
            }
        case .nickname:
            if let s = store.scope(state: \.nickname, action: \.nickname) {
                NicknameView(store: s)
            }
        }
    }
}
