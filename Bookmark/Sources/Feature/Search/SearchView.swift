//
//  SearchView.swift
//  Bookmark
//
//  Created by wodnd on 6/16/26.
//

import SwiftUI
import ComposableArchitecture

struct SearchView: View {
    @Bindable var store: StoreOf<SearchFeature>
    @Shared(.settings) var settings: AppSettings

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                ScreenHeader(title: "책 찾기")
                    .padding(.horizontal, 20)

                // 검색 필드
                HStack(spacing: 10) {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.inkFaint)
                    TextField("책 제목 · 저자 검색", text: $store.query)
                        .font(.sketch(19))
                        .foregroundColor(.ink)
                        .tint(settings.accentColor)
                    if !store.query.isEmpty {
                        Button {
                            store.query = ""
                        } label: {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(.inkFaint)
                        }
                    }
                }
                .padding(12)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.ink, lineWidth: 1.6)
                )
                .padding(.horizontal, 20)
                .padding(.top, 8)
                
                // 결과 영역
                if store.query.isEmpty {
                    Spacer()
                    Text("책 제목이나 저자로 검색해보세요 📚")
                        .font(.sketch(17))
                        .foregroundColor(.inkFaint)
                    Spacer()
                } else if store.isSearching {
                    Spacer()
                    ProgressView()
                        .tint(settings.accentColor)
                    Spacer()
                } else if store.results.isEmpty {
                    Spacer()
                    Text("\"\(store.query)\"에 대한 책이 없어요 ✏️")
                        .font(.sketch(18))
                        .foregroundColor(.inkFaint)
                    Spacer()
                } else {
                    ScrollView {
                        LazyVStack(spacing: 0) {
                            ForEach(store.results) { result in
                                SearchResultRow(
                                    result: result,
                                    added: store.addedBookIds.contains(result.id),
                                    isLoading: store.selectedBook?.id == result.id && store.isLoadingDetail
                                ) {
                                    store.send(.bookSelected(result))
                                }
                                DashedDivider()
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.bottom, 20)
                    }
                    .padding(.top, 16)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.paper)
            .toolbar(.hidden, for: .navigationBar)
        }
        .sheet(item: $store.selectedBook) { book in
            BookAddSheet(
                book: book,
                pages: store.selectedBookPages,
                isLoading: store.isLoadingDetail
            ) {
                let pages = store.selectedBookPages ?? 0
                store.send(.bookAdded(Book(kakao: book, totalPages: pages)))
            }
        }
        .onChange(of: store.selectedBook) { oldValue, newValue in
            if newValue == nil, oldValue != nil {
                store.send(.detailDismissed)
            }
        }
    }
}

// MARK: - 검색 결과 행
struct SearchResultRow: View {
    var result: KakaoBookResult
    var added: Bool
    var isLoading: Bool
    var onTap: () -> Void
    @Shared(.settings) var settings: AppSettings

    var body: some View {
        HStack(spacing: 13) {
            AsyncImage(url: URL(string: result.thumbnail)) { phase in
                if case .success(let image) = phase {
                    image.resizable().scaledToFill()
                } else {
                    Color.ink.opacity(0.08)
                }
            }
            .frame(width: 42, height: 56)
            .clipShape(RoundedRectangle(cornerRadius: 6))

            VStack(alignment: .leading, spacing: 2) {
                Text(result.title)
                    .font(.sketchBold(19))
                    .foregroundColor(.ink)
                    .lineLimit(1)
                Text("\(result.author) · \(result.publisher)")
                    .font(.sketch(14))
                    .foregroundColor(.inkFaint)
                    .lineLimit(1)
            }

            Spacer()

            if added {
                HStack(spacing: 4) {
                    Image(systemName: "checkmark")
                        .font(.system(size: 13, weight: .bold))
                    Text("추가됨")
                        .font(.sketchBold(16))
                }
                .foregroundColor(settings.accentColor)
            } else if isLoading {
                ProgressView()
                    .frame(width: 34, height: 34)
            } else {
                Button(action: onTap) {
                    Image(systemName: "plus")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(width: 34, height: 34)
                        .background(settings.accentColor)
                        .clipShape(Circle())
                }
            }
        }
        .padding(.vertical, 12)
        .contentShape(Rectangle())
    }
}

// MARK: - 책 추가 확인 시트
struct BookAddSheet: View {
    var book: KakaoBookResult
    var pages: Int?
    var isLoading: Bool
    var onAdd: () -> Void
    @Shared(.settings) var settings: AppSettings
    @Environment(\.dismiss) private var dismiss
    @State private var contentsExpanded = false
    @State private var detent: PresentationDetent = .medium

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                Capsule()
                    .fill(Color.ink.opacity(0.2))
                    .frame(width: 44, height: 5)
                    .padding(.top, 12)

                AsyncImage(url: URL(string: book.thumbnail)) { phase in
                    if case .success(let image) = phase {
                        image.resizable().scaledToFill()
                    } else {
                        Color.ink.opacity(0.08)
                    }
                }
                .frame(width: 96, height: 128)
                .clipShape(RoundedRectangle(cornerRadius: 8))
                .padding(.top, 8)

                Text(book.title)
                    .font(.sketchBold(22))
                    .foregroundColor(.ink)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 24)

                VStack(spacing: 2) {
                    Text(authorLine)
                        .font(.sketch(15))
                        .foregroundColor(.inkFaint)
                    if let date = book.publishedDate {
                        Text("\(book.publisher) · \(date)")
                            .font(.sketch(13))
                            .foregroundColor(.inkFaint)
                    } else {
                        Text(book.publisher)
                            .font(.sketch(13))
                            .foregroundColor(.inkFaint)
                    }
                }

                if isLoading {
                    ProgressView()
                        .tint(settings.accentColor)
                        .padding(.top, 4)
                } else if let pages, pages > 0 {
                    Text("전체 \(pages)쪽")
                        .font(.sketch(16))
                        .foregroundColor(.inkSoft)
                } else {
                    Text("페이지 정보를 찾지 못했어요")
                        .font(.sketch(14))
                        .foregroundColor(.inkFaint)
                }

                if !book.contents.isEmpty {
                    VStack(alignment: .leading, spacing: 6) {
                        Text(book.contents)
                            .font(.sketch(15))
                            .foregroundColor(.ink.opacity(0.8))
                            .multilineTextAlignment(.leading)
                            .lineLimit(contentsExpanded ? nil : 1)
                            .frame(maxWidth: .infinity, alignment: .leading)

                        Button {
                            withAnimation(.easeOut(duration: 0.25)) {
                                contentsExpanded.toggle()
                                detent = contentsExpanded ? .large : .medium
                            }
                        } label: {
                            Text(contentsExpanded ? "접기" : "더보기")
                                .font(.sketchBold(13))
                                .foregroundColor(settings.accentColor)
                        }
                    }
                    .padding(14)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.ink.opacity(0.15), lineWidth: 1.2)
                    )
                    .padding(.horizontal, 24)
                    .padding(.top, 4)
                }

                Button {
                    onAdd()
                    dismiss()
                } label: {
                    Text("서재에 추가하기")
                        .font(.sketchBold(20))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 13)
                        .background(settings.accentColor)
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                }
                .disabled(isLoading)
                .opacity(isLoading ? 0.5 : 1)
                .padding(.horizontal, 22)
                .padding(.top, 8)
                .padding(.bottom, 30)
            }
        }
        .background(Color.paper)
        .presentationDetents([.medium, .large], selection: $detent)
        .presentationDragIndicator(.hidden)
        .presentationBackground(Color.paper)
    }

    private var authorLine: String {
        guard !book.translators.isEmpty else { return book.author }
        return "\(book.author) · \(book.translators.joined(separator: ", ")) 옮김"
    }
}

#Preview {
    SearchView(
        store: Store(initialState: SearchFeature.State()) {
            SearchFeature()
        }
    )
}
