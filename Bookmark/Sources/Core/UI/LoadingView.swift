//
//  LoadingView.swift
//  Bookmark
//
//  Created by wodnd on 6/15/26.
//

import SwiftUI
import ComposableArchitecture

struct LoadingView: View {
    @Shared(.settings) var settings: AppSettings
    @State private var isAnimating = false
    
    var body: some View {
        ZStack {
            Color.gray
                .opacity(0.8)
                .ignoresSafeArea()
            
            VStack(spacing: 20) {
                Image(settings.iconName)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 80)
                    .scaleEffect(isAnimating ? 1.15 : 0.95)
                    .rotationEffect(.degrees(isAnimating ? 8 : -8))
                    .animation(.easeInOut(duration: 0.6)
                        .repeatForever(autoreverses: true), value: isAnimating)
                
                Text("잠깐만요...")
                    .font(.sketch(17))
                    .foregroundColor(.inkSoft)
                    .opacity(isAnimating ? 1 : 0.5)
                    .animation(.easeInOut(duration: 0.6)
                        .repeatForever(autoreverses: true), value: isAnimating)
            }
        }
        .onAppear {
            isAnimating = true
        }
    }
}

#Preview {
    LoadingView()
}
