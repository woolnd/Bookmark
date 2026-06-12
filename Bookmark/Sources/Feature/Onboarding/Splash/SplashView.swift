//
//  SplashView.swift
//  Bookmark
//
//  Created by wodnd on 6/12/26.
//

import SwiftUI
import ComposableArchitecture

struct SplashView: View {
    @Bindable var store: StoreOf<SplashFeature>
    @Shared(.settings) var settings: AppSettings

    var body: some View {
        VStack(spacing: 14) {
            Image(settings.iconName)
                .resizable()
                .scaledToFit()
                .frame(width: 100)
                .opacity(store.isVisible ? 1 : 0)
                .offset(y: store.isVisible ? 0 : 12)
                .animation(.easeOut(duration: 0.6), value: store.isVisible)

            Text("책갈피")
                .font(.sketchBold(48))
                .foregroundColor(.ink)
                .opacity(store.isVisible ? 1 : 0)
                .offset(y: store.isVisible ? 0 : 12)
                .animation(.easeOut(duration: 0.6).delay(0.15), value: store.isVisible)

            WavyLine(width: 90, color: settings.accentColor, lineWidth: 2.8)
                .opacity(store.isVisible ? 1 : 0)
                .scaleEffect(x: store.isVisible ? 1 : 0, anchor: .leading)
                .animation(.easeOut(duration: 0.5).delay(0.35), value: store.isVisible)

            Text("취향의 독서를 함께")
                .font(.sketch(19))
                .foregroundColor(.inkSoft)
                .opacity(store.isVisible ? 1 : 0)
                .offset(y: store.isVisible ? 0 : 12)
                .animation(.easeOut(duration: 0.6).delay(0.45), value: store.isVisible)
        }
        .onAppear { store.send(.onAppear) }
        .contentShape(Rectangle())
        .onTapGesture { store.send(.finished) }
    }
}

#Preview {
    SplashView(
        store: Store(initialState: SplashFeature.State()) {
            SplashFeature()
        }
    )
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .background(Color.paper)
}
