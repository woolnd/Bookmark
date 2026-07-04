//
//  HomeView.swift
//  Bookmark-Dev
//
//  Created by wodnd on 6/16/26.
//

import SwiftUI
import ComposableArchitecture

struct HomeView: View {
    @Bindable var store: StoreOf<HomeFeature>
    @Shared(.settings) var settings: AppSettings
    
    private let collapseAt = 3
    
    private var visibleBooks: [Book] {
        store.showAll ? store.books : Array(store.books.prefix(collapseAt))
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                ScreenHeader(title: "책갈피", trailingIcon: "gearshape", showLogo: true) {
                    // 설정 시트 추후 연결
                }

                // MARK: - 읽는 중 섹션
                SectionLabel(text: "읽는 중", underlineWidth: 62)
                    .padding(.bottom, 10)
                
                if store.books.isEmpty {
                    EmptyStateView(
                        emoji: "📖",
                        title: "아직 읽는 책이 없어요",
                        sub: "검색에서 첫 책을 꽂아보세요"
                    ) {
                        store.send(.goToSearchTapped)
                    }
                } else {
                    ForEach(visibleBooks) { book in
                        MyBookCard(book: book)
                            .onTapGesture {
                                store.send(.bookCardTapped(book))
                            }
                            .padding(.bottom, 14)
                    }
                    
                    if store.books.count > collapseAt {
                        Button {
                            withAnimation(.easeOut(duration: 0.2)) {
                                _ = store.send(.showAllToggled)
                            }
                        } label: {
                            Text(store.showAll
                                 ? "접기 ▴"
                                 : "\(store.books.count - collapseAt)권 더 보기 ▾")
                            .font(.sketchBold(16))
                            .foregroundColor(.inkSoft)
                            .frame(maxWidth: .infinity)
                        }
                        .padding(.bottom, 8)
                    }
                }
                
                // MARK: - 친구들 소식 섹션
                SectionLabel(text: "친구들 소식", underlineWidth: 104)
                    .padding(.top, 12)
                    .padding(.bottom, 8)
                
                if store.friends.isEmpty {
                    EmptyStateView(
                        emoji: "👋",
                        title: "아직 친구가 없어요",
                        sub: "친구 탭에서 코드로 추가해보세요"
                    ) {
                        store.send(.goToFriendsTapped)
                    }
                } else {
                    ForEach(store.friends) { friend in
                        FeedRow(friend: friend)
                            .onTapGesture {
                                store.send(.friendFeedTapped(friend))
                            }
                        DashedDivider()
                    }
                }
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 20)
        }
        .background(Color.paper)
        .toolbar(.hidden, for: .navigationBar)
    }
}

//MARK: - 내 책 카드
struct MyBookCard: View {
    var book: Book
    @Shared(.settings) var settings: AppSettings
    
    var body: some View {
        HStack(spacing: 14) {
            BookCoverView(seed: book.seed, coverURL: book.coverURL, width: 52, height: 68)
            VStack(alignment: .leading, spacing: 4) {
                HStack(alignment: .firstTextBaseline) {
                    Text(book.title)
                        .font(.sketchBold(20))
                        .foregroundColor(.ink)
                        .lineLimit(1)
                    
                    Spacer()
                    
                    Text("\(book.percent)")
                        .font(.sketchBold(23))
                        .foregroundColor(settings.accentColor)
                }
                Text(book.author)
                    .font(.sketch(15))
                    .foregroundColor(.inkFaint)
                SketchProgressBar(progress: book.progress, width: 200)
                HStack(spacing: 8) {
                    Text("\(book.currentPage)쪽 · 전체 \(book.totalPages)쪽")
                        .font(.sketch(14))
                        .foregroundColor(.inkSoft)
                    if !book.loggedToday {
                        Circle()
                            .fill(settings.accentColor.opacity(0.7))
                            .frame(width: 7, height: 7)
                    }
                }
            }
        }
        .padding(14)
        .sketchBorder(seed: book.seed % 2)
        .contentShape(Rectangle())
    }
}


//MARK: - 친구 피드 행
struct FeedRow: View {
    var friend: Friend
    @Shared(.settings) var settings: AppSettings
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            AvatarView(label: friend.initial, size: 40)
            VStack(alignment: .leading, spacing: 3) {
                HStack(alignment: .firstTextBaseline, spacing: 6) {
                    Text(friend.name)
                        .font(.sketchBold(18))
                        .foregroundColor(.ink)
                    Text("· \(friend.when)")
                        .font(.sketch(14))
                        .foregroundColor(.inkFaint)
                    Spacer()
                    Image(systemName: "chevron.right")
                        .font(.system(size: 11))
                        .foregroundColor(.inkFaint)
                }
                Text("『\(friend.feedTitle)』 \(friend.feedPercent)% 읽었어요")
                    .font(.sketch(16))
                    .foregroundColor(.inkSoft)
                if !friend.note.isEmpty {
                    Text("\"\(friend.note)\"")
                        .font(.sketch(15))
                        .foregroundColor(.ink.opacity(0.85))
                }
                SketchProgressBar(progress: friend.feedProgress, width: 150, lineWidth: 3)
                    .padding(.top, 4)
            }
        }
        .padding(.vertical, 13)
        .contentShape(Rectangle())
    }
}

//MARK: - 빈 상태
struct EmptyStateView: View {
    var emoji: String
    var title: String
    var sub: String
    var action: () -> Void
    @Shared(.settings) var settings: AppSettings

    var body: some View {
        Button(action: action) {
            VStack(spacing: 10) {
                Text(emoji).font(.system(size: 32))
                Text(title)
                    .font(.sketchBold(18))
                    .foregroundColor(.ink)
                Text(sub)
                    .font(.sketch(15))
                    .foregroundColor(.inkFaint)

                HStack(spacing: 5) {
                    Image(systemName: "plus.circle.fill")
                        .font(.system(size: 14))
                    Text("바로 가기")
                        .font(.sketchBold(14))
                }
                .foregroundColor(settings.accentColor)
                .padding(.horizontal, 14)
                .padding(.vertical, 7)
                .overlay(
                    Capsule().stroke(settings.accentColor, lineWidth: 1.6)
                )
                .padding(.top, 4)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 26)
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    HomeView(
        store: Store(initialState: HomeFeature.State(
            books: Book.samples,
            friends: Friend.samples
        )) {
            HomeFeature()
        }
    )
}
