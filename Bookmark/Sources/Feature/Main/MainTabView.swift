//
//  MainTabView.swift
//  Bookmark
//
//  Created by wodnd on 6/12/26.
//

import SwiftUI
import ComposableArchitecture

struct MainTabView: View {
    @Bindable var store: StoreOf<MainFeature>
    
    var body: some View {
        TabView(selection: $store.selectedTab.sending(\.tabSelected)) {
            HomeView(store: store.scope(state: \.home, action: \.home))
                .tabItem { Label("홈", systemImage: "house") }
                .tag(MainFeature.Tab.home)
            
            Text("검색")
                .tabItem { Label("검색", systemImage: "magnifyingglass") }
                .tag(MainFeature.Tab.search)
            
            Text("친구")
                .tabItem { Label("친구", systemImage: "person.2") }
                .tag(MainFeature.Tab.friends)
            
            Text("읽은 책")
                .tabItem { Label("읽은 책", systemImage: "books.vertical") }
                .tag(MainFeature.Tab.library)
        }
    }
}

#Preview {
    MainTabView(
        store: Store(initialState: MainFeature.State()) {
            MainFeature()
        }
    )
}
