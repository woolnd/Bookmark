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
