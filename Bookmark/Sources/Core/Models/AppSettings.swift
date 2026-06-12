//
//  AppSettings.swift
//  Bookmark
//
//  Created by wodnd on 6/12/26.
//

import Foundation
import SwiftUI

struct AppSettings: Equatable, Codable {
    var accentHex: String = "#E0533C"
    var isHandwritingFont: Bool = true
    var paperTexture: Bool = false

    var accentColor: Color { Color(hex: accentHex) }
    var accentWash: Color { accentColor.opacity(0.12) }
}

extension AppSettings {
    var iconName: String {
        switch accentHex {
        case "#E0533C": return "icon_coral"
        case "#3E6FB0": return "icon_blue"
        case "#2E7D5B": return "icon_green"
        case "#9B5DE0": return "icon_violet"
        case "#D9962B": return "icon_mustard"
        case "#1A1A1A": return "icon_ink"
        default: return "icon_coral"
        }
    }
}
