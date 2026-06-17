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
    @Shared(.settings) var settings: AppSettings
    
    var body: some View {
        ZStack(alignment: .bottom) {
            // 탭 콘텐츠
            Group {
                switch store.selectedTab {
                case .home:
                    HomeView(store: store.scope(state: \.home, action: \.home))
                case .search:
                    SearchView(store: store.scope(state: \.search, action: \.search))
                case .friends:
                    Text("친구")
                case .library:
                    Text("읽은 책")
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            
            // 커스텀 탭바
            CustomTabBar(selectedTab: $store.selectedTab.sending(\.tabSelected))
        }
        .ignoresSafeArea(.keyboard)
        .onAppear {
            store.send(.onAppear)
        }
    }
}

// MARK: - 커스텀 탭바
struct CustomTabBar: View {
    @Binding var selectedTab: MainFeature.Tab
    @Shared(.settings) var settings: AppSettings
    
    var body: some View {
        HStack(spacing: 0) {
            TabBarButton(
                icon: "house",
                filledIcon: "house.fill",
                label: "홈",
                isSelected: selectedTab == .home
            ) {
                selectedTab = .home
            }
            TabBarButton(
                icon: "magnifyingglass",
                filledIcon: "magnifyingglass",
                label: "검색",
                isSelected: selectedTab == .search
            ) {
                selectedTab = .search
            }
            TabBarButton(
                icon: "person.2",
                filledIcon: "person.2.fill",
                label: "친구",
                isSelected: selectedTab == .friends
            ) {
                selectedTab = .friends
            }
            TabBarButton(
                icon: "books.vertical",
                filledIcon: "books.vertical.fill",
                label: "읽은 책",
                isSelected: selectedTab == .library
            ) {
                selectedTab = .library
            }
        }
        .padding(.top, 10)
        .padding(.bottom, 8)
        .background(
            Color.paper
                .overlay(Rectangle().frame(height: 1).foregroundColor(.ink.opacity(0.12)), alignment: .top)
                .ignoresSafeArea()
        )
    }
}

struct TabBarButton: View {
    var icon: String
    var filledIcon: String
    var label: String
    var isSelected: Bool
    var action: () -> Void
    @Shared(.settings) var settings: AppSettings
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 3) {
                Image(systemName: isSelected ? filledIcon : icon)
                    .font(.system(size: 22))
                Text(label)
                    .font(.sketch(11))
            }
            .foregroundColor(isSelected ? settings.accentColor : .inkFaint)
            .frame(maxWidth: .infinity)
        }
    }
}

