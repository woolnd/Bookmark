//
//  Theme.swift
//  Bookmark
//
//  Created by wodnd on 6/12/26.
//

// Theme.swift
// 책갈피 — 디자인 토큰 (색상, 폰트, 포인트 색 옵션)
import Foundation
import SwiftUI

// MARK: - Colors
extension Color {
    static let ink       = Color(hex: "#1A1A1A")
    static let inkSoft   = Color(hex: "#55524C")
    static let inkFaint  = Color(hex: "#9A968E")
    static let paper     = Color(hex: "#FFF9F5")

    init(hex: String) {
        let h = hex.trimmingCharacters(in: CharacterSet(charactersIn: "#"))
        var rgb: UInt64 = 0
        Scanner(string: h).scanHexInt64(&rgb)
        self.init(
            red:   Double((rgb >> 16) & 0xFF) / 255,
            green: Double((rgb >>  8) & 0xFF) / 255,
            blue:  Double( rgb        & 0xFF) / 255
        )
    }
}

// MARK: - Fonts
// Gaegu-Light.ttf, Gaegu-Regular.ttf, Gaegu-Bold.ttf 를 번들에 추가하고
// Project.swift의 UIAppFonts 배열에 등록하세요.
// https://fonts.google.com/specimen/Gaegu
extension Font {
    /// 기본(Regular) 손글씨 폰트
    static func sketch(_ size: CGFloat) -> Font {
        .custom("Gaegu-Regular", size: size)
    }
    /// Bold 손글씨 폰트
    static func sketchBold(_ size: CGFloat) -> Font {
        .custom("Gaegu-Bold", size: size)
    }
    /// Light 손글씨 폰트
    static func sketchLight(_ size: CGFloat) -> Font {
        .custom("Gaegu-Light", size: size)
    }
}

// MARK: - 포인트 색 옵션 (설정 / Tweaks)
struct AccentOption: Identifiable {
    let id = UUID()
    let name: String
    let hex: String
    var color: Color { Color(hex: hex) }
}

let accentOptions: [AccentOption] = [
    AccentOption(name: "코랄",    hex: "#E0533C"),
    AccentOption(name: "블루",    hex: "#3E6FB0"),
    AccentOption(name: "그린",    hex: "#2E7D5B"),
    AccentOption(name: "바이올렛", hex: "#9B5DE0"),
    AccentOption(name: "머스터드", hex: "#D9962B"),
    AccentOption(name: "먹색",    hex: "#1A1A1A"),
]
