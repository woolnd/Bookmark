//
//  WavyLine.swift
//  Bookmark
//
//  Created by wodnd on 6/12/26.
//

import Foundation
import SwiftUI

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
