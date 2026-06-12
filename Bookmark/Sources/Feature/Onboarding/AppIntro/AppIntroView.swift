//
//  AppIntroView.swift
//  Bookmark-Dev
//
//  Created by wodnd on 6/12/26.
//

import SwiftUI
import ComposableArchitecture

struct AppIntroView: View {
    @Bindable var store: StoreOf<AppIntroFeature>
    @Shared(.settings) var settings: AppSettings

    var body: some View {
        VStack(spacing: 0) {
            Spacer()

            Image(settings.iconName)
                .resizable()
                .scaledToFit()
                .frame(width: 68)

            Text("독서를 더 재밌게")
                .font(.sketchBold(30))
                .foregroundColor(.ink)
                .padding(.top, 18)
                .padding(.bottom, 20)

            WavyLine(width: 110, color: settings.accentColor, lineWidth: 2.4)

            VStack(spacing: 0) {
                FeatureRow(emoji: "📖", title: "진행률 기록", desc: "지금 읽는 쪽을 휠 피커로 빠르게 입력해요")
                FeatureRow(emoji: "👥", title: "친구와 공유", desc: "친구 코드로 연결하고 서로 진행률을 확인해요")
                FeatureRow(emoji: "📱", title: "위젯으로 한눈에", desc: "홈 화면에서 바로 진행률을 확인해요")
            }
            .padding(.horizontal, 28)
            .padding(.top, 20)

            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.paper)
        .safeAreaInset(edge: .bottom) {
            SketchButton(label: "시작하기", fill: false, accent: true) {
                store.send(.startTapped)
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 16)
            .background(Color.paper)
        }
    }
}

#Preview {
    AppIntroView(
        store: Store(initialState: AppIntroFeature.State()) {
            AppIntroFeature()
        }
    )
}
