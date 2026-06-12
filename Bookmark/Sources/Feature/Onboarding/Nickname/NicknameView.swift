//
//  NicknameView.swift
//  Bookmark-Dev
//
//  Created by wodnd on 6/13/26.
//

import SwiftUI
import ComposableArchitecture

struct NicknameView: View {
    
    @Bindable var store: StoreOf<NicknameFeature>
    @Shared(.settings) var settings: AppSettings
    
    private let suggestions = ["책벌레", "밤독서러", "독서중독", "페이지터너", "북마크"]
    private let maxLen = 12
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("닉네임을 알려주세요")
                .font(.sketchBold(30))
                .foregroundColor(.ink)
                .padding(.top, 70)
                .padding(.bottom, 10)
            
            WavyLine(width: 160, color: settings.accentColor, lineWidth: 2.4)
            
            Text("친구에게 보여지는 이름이에요")
                .font(.sketch(17))
                .foregroundColor(.inkSoft)
                .padding(.top, 8)
                .padding(.bottom, 28)
            
            HStack {
                TextField("예: 책읽는 고양이", text: $store.nickname.sending(\.nicknameChanged))
                    .font(.sketchBold(22))
                    .foregroundColor(.ink)
                    .tint(settings.accentColor)
                Text("\(store.nickname.count)/\(maxLen))")
                    .font(.sketch(14))
                    .foregroundColor(store.nickname.isEmpty ? .inkFaint: settings.accentColor)
            }
            .padding(14)
            .overlay(
                Capsule().stroke(store.nickname.isEmpty ? Color.ink : settings.accentColor, lineWidth: 2)
            )
            .padding(.bottom, 18)
            
            Text("이런 이름은 어때요?")
                .font(.sketch(15))
                .foregroundColor(.inkFaint)
            
            FlowChips(options: suggestions, selected: store.nickname) {
                store.send(.suggestionTapped($0))
            }
            .padding(.top, 8)
            
            Spacer()
            
            SketchButton(
                label: "완료",
                fill: false,
                accent: true,
                disabled: store.nickname.trimmingCharacters(in: .whitespaces).isEmpty || store.isSaving
            ) {
                store.send(.doneTapped)
            }
            .padding(.top, 16)
            .padding(.bottom, 44)
        }
        .padding(.horizontal, 24)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.paper)
    }
}

// MARK: - 추천 닉네임 칩
struct FlowChips: View {
    var options: [String], selected: String
    var onPick: (String) -> Void
    @Shared(.settings) var settings: AppSettings
    
    var body: some View {
        FlowLayout(spacing: 9) {
            ForEach(options, id: \.self) { n in
                Button { onPick(n) } label: {
                    Text(n).font(.sketchBold(15))
                        .foregroundColor(selected == n ? .white : .ink)
                        .padding(.horizontal, 14).padding(.vertical, 6)
                        .background(Capsule().fill(selected == n ? settings.accentColor : .clear))
                        .overlay(Capsule().stroke(selected == n ? settings.accentColor : .ink.opacity(0.35), lineWidth: 1.8))
                }
            }
        }
    }
}

// MARK: - 가로 흐름 레이아웃
struct FlowLayout: Layout {
    var spacing: CGFloat = 8
    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let width = proposal.width ?? 300
        var x: CGFloat = 0, y: CGFloat = 0, rowH: CGFloat = 0
        for s in subviews {
            let sz = s.sizeThatFits(.unspecified)
            if x + sz.width > width { x = 0; y += rowH + spacing; rowH = 0 }
            x += sz.width + spacing
            rowH = max(rowH, sz.height)
        }
        return CGSize(width: width, height: y + rowH)
    }
    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        var x = bounds.minX, y = bounds.minY, rowH: CGFloat = 0
        for s in subviews {
            let sz = s.sizeThatFits(.unspecified)
            if x + sz.width > bounds.maxX { x = bounds.minX; y += rowH + spacing; rowH = 0 }
            s.place(at: CGPoint(x: x, y: y), proposal: .unspecified)
            x += sz.width + spacing
            rowH = max(rowH, sz.height)
        }
    }
}

#Preview {
    NicknameView(
        store: Store(initialState: NicknameFeature.State(uid: ""), reducer: {
            NicknameFeature()
        })
    )
}
