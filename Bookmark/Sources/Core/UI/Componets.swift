//
//  Componets.swift
//  Bookmark-Dev
//
//  Created by wodnd on 6/12/26.
//

// Components.swift
// 책갈피 — 공용 손그림 UI 컴포넌트
// (SketchRect, sketchBorder, BookCoverView, SketchProgressBar,
//  AvatarView, SketchButton, ToastView, DashedDivider, WavyLine,
//  FeatureRow, PageDots)

import SwiftUI
import ComposableArchitecture

// MARK: - 손그림 사각형 테두리 (seed 기반 흔들림)
struct SketchRect: Shape {
    var cornerRadius: CGFloat = 14
    var seed: Int = 0

    private func j(_ n: Int) -> CGFloat {
        let v = (seed &* 37 &+ n &* 13) % 9
        return CGFloat(v) - 4.0
    }

    func path(in rect: CGRect) -> Path {
        let r = rect.insetBy(dx: 2, dy: 2)
        let cr = cornerRadius
        var p = Path()
        p.move(to: CGPoint(x: r.minX + cr + j(0), y: r.minY + j(1)))
        p.addLine(to: CGPoint(x: r.maxX - cr + j(2), y: r.minY + j(3)))
        p.addQuadCurve(to: CGPoint(x: r.maxX + j(4), y: r.minY + cr + j(5)),
                       control: CGPoint(x: r.maxX + j(6), y: r.minY + j(7)))
        p.addLine(to: CGPoint(x: r.maxX + j(8), y: r.maxY - cr + j(9)))
        p.addQuadCurve(to: CGPoint(x: r.maxX - cr + j(10), y: r.maxY + j(11)),
                       control: CGPoint(x: r.maxX + j(12), y: r.maxY + j(13)))
        p.addLine(to: CGPoint(x: r.minX + cr + j(14), y: r.maxY + j(15)))
        p.addQuadCurve(to: CGPoint(x: r.minX + j(16), y: r.maxY - cr + j(17)),
                       control: CGPoint(x: r.minX + j(18), y: r.maxY + j(19)))
        p.addLine(to: CGPoint(x: r.minX + j(20), y: r.minY + cr + j(21)))
        p.addQuadCurve(to: CGPoint(x: r.minX + cr + j(0), y: r.minY + j(1)),
                       control: CGPoint(x: r.minX + j(22), y: r.minY + j(23)))
        p.closeSubpath()
        return p
    }
}

struct SketchBorder: ViewModifier {
    var seed: Int = 0
    var color: Color = .ink
    var fill: Color = .clear
    var lineWidth: CGFloat = 2
    func body(content: Content) -> some View {
        content.overlay(
            SketchRect(seed: seed).fill(fill)
                .overlay(SketchRect(seed: seed).stroke(color, lineWidth: lineWidth))
        )
    }
}
extension View {
    func sketchBorder(seed: Int = 0, color: Color = .ink, fill: Color = .clear, lineWidth: CGFloat = 2) -> some View {
        modifier(SketchBorder(seed: seed, color: color, fill: fill, lineWidth: lineWidth))
    }
}

// MARK: - 책 표지 두들 (seed로 모티프/모양 결정)
private let motifSymbols = [
    "star.fill", "moon.fill", "mountain.2.fill", "leaf.fill",
    "waveform", "sun.max.fill", "cup.and.saucer.fill", "heart.fill"
]

struct BookCoverView: View {
    var seed: Int = 0
    var width: CGFloat = 52
    var height: CGFloat = 68
    var tilt: Bool = true
    @Shared(.settings) var settings: AppSettings

    private var rotation: Double { tilt ? Double((seed * 37) % 7) - 3 : 0 }
    private var symbol: String { motifSymbols[((seed % motifSymbols.count) + motifSymbols.count) % motifSymbols.count] }

    var body: some View {
        ZStack {
            SketchRect(seed: seed).fill(Color.paper)
            SketchRect(seed: seed).stroke(Color.ink, lineWidth: 1.8)
            Rectangle().frame(width: 1.4).foregroundColor(.ink.opacity(0.55))
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.leading, width * 0.18)
            VStack(spacing: 4) {
                Image(systemName: symbol)
                    .font(.system(size: width * 0.28, weight: .light))
                    .foregroundColor(settings.accentColor)
                Spacer()
                VStack(spacing: 5) {
                    RoundedRectangle(cornerRadius: 2).frame(width: width * 0.6, height: 1.6).foregroundColor(.ink.opacity(0.5))
                    RoundedRectangle(cornerRadius: 2).frame(width: width * 0.44, height: 1.6).foregroundColor(.ink.opacity(0.35))
                }
            }
            .padding(8).padding(.leading, width * 0.15)
        }
        .frame(width: width, height: height)
        .rotationEffect(.degrees(rotation))
    }
}

// MARK: - 진행 바
struct SketchProgressBar: View {
    var progress: Double
    var width: CGFloat = 160
    var lineWidth: CGFloat = 4
    @Shared(.settings) var settings: AppSettings

    var body: some View {
        ZStack(alignment: .leading) {
            Capsule().frame(width: width, height: lineWidth).foregroundColor(.ink.opacity(0.15))
            Capsule()
                .frame(width: max(0, width * CGFloat(min(progress, 1))), height: lineWidth)
                .foregroundColor(settings.accentColor)
        }
    }
}

// MARK: - 아바타
struct AvatarView: View {
    var label: String
    var size: CGFloat = 36
    var accent: Bool = false
    @Shared(.settings) var settings: AppSettings

    var body: some View {
        ZStack {
            SketchRect(cornerRadius: size / 2, seed: label.hashValue)
                .fill(accent ? settings.accentColor.opacity(0.12) : Color.paper)
            SketchRect(cornerRadius: size / 2, seed: label.hashValue)
                .stroke(accent ? settings.accentColor : .ink, lineWidth: 2)
            Text(label).font(.sketchBold(size * 0.44))
                .foregroundColor(accent ? settings.accentColor : .ink)
        }
        .frame(width: size, height: size)
    }
}

// MARK: - 버튼
struct SketchButton: View {
    var label: String
    var fill: Bool = false
    var accent: Bool = false
    var small: Bool = false
    var disabled: Bool = false
    var action: () -> Void

    @Shared(.settings) var settings: AppSettings
    @State private var pressed = false

    private var fg: Color { fill ? .white : (accent ? settings.accentColor : .ink) }
    private var bg: Color { fill ? (accent ? settings.accentColor : .ink) : .clear }
    private var border: Color { accent ? settings.accentColor : .ink }

    var body: some View {
        Button(action: action) {
            ZStack {
                Text(label)
                    .font(.sketchBold(small ? 17 : 20))
                    .foregroundColor(fg)
                    .frame(maxWidth: small ? nil : .infinity, alignment: .center)
                    .padding(small ? EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16)
                                   : EdgeInsets(top: 12, leading: 20, bottom: 12, trailing: 20))
                    .background(bg)
                    .sketchBorder(seed: label.hashValue, color: border, fill: bg)
            }
        }
        .opacity(disabled ? 0.4 : 1)
        .disabled(disabled)
        .scaleEffect(pressed ? 0.96 : 1)
        .animation(.easeOut(duration: 0.12), value: pressed)
        .simultaneousGesture(DragGesture(minimumDistance: 0)
            .onChanged { _ in pressed = true }.onEnded { _ in pressed = false })
    }
}

// MARK: - 토스트
struct ToastView: View {
    var message: String
    var body: some View {
        Text(message)
            .font(.sketchBold(17)).foregroundColor(.white)
            .padding(.horizontal, 20).padding(.vertical, 10)
            .background(Capsule().fill(Color.ink))
            .shadow(color: .black.opacity(0.25), radius: 10, y: 4)
            .transition(.scale(scale: 0.8).combined(with: .opacity))
    }
}

// MARK: - 점선 구분선
struct DashedDivider: View {
    var body: some View {
        GeometryReader { geo in
            Path { p in
                p.move(to: CGPoint(x: 0, y: 0.5))
                p.addLine(to: CGPoint(x: geo.size.width, y: 0.5))
            }
            .stroke(Color.ink.opacity(0.22), style: StrokeStyle(lineWidth: 1.5, dash: [5, 4]))
        }
        .frame(height: 1)
    }
}

// MARK: - 물결 밑줄
struct WavyLine: View {
    var width: CGFloat
    var height: CGFloat = 6
    var color: Color
    var lineWidth: CGFloat = 2.4

    var body: some View {
        Canvas { ctx, size in
            var path = Path()
            let mid = size.height / 2
            path.move(to: CGPoint(x: 0, y: mid))
            path.addQuadCurve(to: CGPoint(x: size.width * 0.32, y: mid),
                              control: CGPoint(x: size.width * 0.16, y: mid - 3))
            path.addQuadCurve(to: CGPoint(x: size.width * 0.66, y: mid),
                              control: CGPoint(x: size.width * 0.5, y: mid + 3))
            path.addQuadCurve(to: CGPoint(x: size.width, y: mid - 1),
                              control: CGPoint(x: size.width * 0.84, y: mid - 2))
            ctx.stroke(path, with: .color(color),
                       style: StrokeStyle(lineWidth: lineWidth, lineCap: .round))
        }
        .frame(width: width, height: height)
    }
}

// MARK: - 온보딩 - 기능 소개 행
struct FeatureRow: View {
    var emoji: String, title: String, desc: String
    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            Text(emoji).font(.system(size: 30))
            VStack(alignment: .leading, spacing: 3) {
                Text(title).font(.sketchBold(20)).foregroundColor(.ink)
                Text(desc).font(.sketch(16)).foregroundColor(.inkSoft)
            }
            Spacer()
        }
        .padding(.vertical, 13)
        .overlay(DashedDivider(), alignment: .bottom)
    }
}

// MARK: - 온보딩 - 페이지 인디케이터
struct PageDots: View {
    var total: Int, current: Int
    @Shared(.settings) var settings: AppSettings

    var body: some View {
        HStack(spacing: 7) {
            ForEach(0..<total, id: \.self) { i in
                Capsule()
                    .fill(i == current ? settings.accentColor : Color.ink.opacity(0.18))
                    .frame(width: i == current ? 22 : 8, height: 8)
                    .animation(.easeOut(duration: 0.25), value: current)
            }
        }
        .frame(maxWidth: .infinity)
    }
}
