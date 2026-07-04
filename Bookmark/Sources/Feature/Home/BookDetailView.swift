//
//  BookDetailView.swift
//  Bookmark
//
//  Created by wodnd on 7/5/26.
//

import SwiftUI
import ComposableArchitecture

struct BookDetailView: View {
    @Bindable var store: StoreOf<BookDetailFeature>
    @Shared(.settings) var settings: AppSettings

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {

                // MARK: - 책 정보 헤더
                HStack(spacing: 16) {
                    BookCoverView(
                        seed: store.book.seed,
                        coverURL: store.book.coverURL,
                        width: 80,
                        height: 110
                    )

                    VStack(alignment: .leading, spacing: 6) {
                        Text(store.book.title)
                            .font(.sketchBold(20))
                            .foregroundColor(.ink)
                            .lineLimit(2)

                        Text(store.book.author)
                            .font(.sketch(15))
                            .foregroundColor(.inkFaint)

                        Spacer()

                        VStack(alignment: .leading, spacing: 4) {
                            HStack {
                                Text("\(store.book.currentPage)쪽")
                                    .font(.sketchBold(16))
                                    .foregroundColor(.ink)
                                Text("/ 전체 \(store.book.totalPages)쪽")
                                    .font(.sketch(14))
                                    .foregroundColor(.inkFaint)
                                Spacer()
                                Text("\(store.book.percent)%")
                                    .font(.sketchBold(18))
                                    .foregroundColor(settings.accentColor)
                            }
                            GeometryReader { geo in
                                SketchProgressBar(
                                    progress: store.book.progress,
                                    width: geo.size.width
                                )
                            }
                            .frame(height: 4)
                        }
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 20)
                .padding(.bottom, 20)

                DashedDivider()
                    .padding(.horizontal, 20)

                // MARK: - 기록하기 / 다시읽기 버튼
                if store.book.isFinished {
                    Button {
                        store.send(.restartBook)
                    } label: {
                        HStack {
                            Image(systemName: "arrow.counterclockwise")
                                .font(.system(size: 15))
                            Text("다시 읽기")
                                .font(.sketchBold(17))
                        }
                        .foregroundColor(settings.accentColor)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 13)
                        .overlay(
                            RoundedRectangle(cornerRadius: 14)
                                .stroke(settings.accentColor, lineWidth: 1.6)
                        )
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 20)
                } else {
                    Button {
                        store.send(.progressSheetPresented)
                    } label: {
                        HStack {
                            Image(systemName: "pencil")
                                .font(.system(size: 15))
                            Text("오늘 읽은 페이지 기록하기")
                                .font(.sketchBold(17))
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 13)
                        .background(settings.accentColor)
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 20)
                }

                // MARK: - 독서 로그 섹션
                SectionLabel(text: "독서 기록", underlineWidth: 72)
                    .padding(.horizontal, 20)
                    .padding(.bottom, 12)

                if store.isLoadingLogs {
                    ProgressView()
                        .tint(settings.accentColor)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 20)
                } else if store.logs.isEmpty {
                    VStack(spacing: 8) {
                        Text("📝")
                            .font(.system(size: 32))
                        Text("아직 기록이 없어요")
                            .font(.sketchBold(17))
                            .foregroundColor(.ink)
                        Text("오늘 읽은 페이지를 기록해보세요")
                            .font(.sketch(14))
                            .foregroundColor(.inkFaint)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 30)
                } else {
                    VStack(spacing: 0) {
                        ForEach(store.logs) { log in
                            ReadingLogRow(log: log)
                            DashedDivider()
                                .padding(.horizontal, 20)
                        }
                    }
                }
            }
            .padding(.bottom, 100)
        }
        .background(Color.paper)
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button {
                    store.send(.dismiss)
                } label: {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.ink)
                }
            }
        }
        .onAppear {
            store.send(.onAppear)
        }
        .sheet(isPresented: $store.isProgressSheetPresented) {
            ProgressUpdateSheet(store: store)
        }
        .sheet(isPresented: $store.isFinishedSheetPresented) {
            FinishedSheet(store: store)
        }
    }
}

// MARK: - 독서 로그 행
struct ReadingLogRow: View {
    var log: ReadingLog
    @Shared(.settings) var settings: AppSettings

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text(log.displayDate)
                    .font(.sketch(13))
                    .foregroundColor(.inkFaint)
                Spacer()
                if log.type == .finished {
                    Text("완독 🎉")
                        .font(.sketchBold(13))
                        .foregroundColor(settings.accentColor)
                } else {
                    Text("\(log.fromPage) → \(log.toPage)쪽")
                        .font(.sketch(13))
                        .foregroundColor(.inkSoft)
                }
            }

            if !log.memo.isEmpty {
                Text(log.memo)
                    .font(.sketch(16))
                    .foregroundColor(.ink)
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 14)
    }
}

// MARK: - 페이지 업데이트 시트 (휠 피커)
struct ProgressUpdateSheet: View {
    @Bindable var store: StoreOf<BookDetailFeature>
    @Shared(.settings) var settings: AppSettings
    @State private var selectedPage: Int = 0

    private var percent: Int {
        store.book.totalPages > 0
            ? Int(Double(selectedPage) / Double(store.book.totalPages) * 100)
            : 0
    }

    private var progress: Double {
        store.book.totalPages > 0
            ? Double(selectedPage) / Double(store.book.totalPages)
            : 0
    }

    var body: some View {
        VStack(spacing: 0) {
            Capsule()
                .fill(Color.ink.opacity(0.2))
                .frame(width: 44, height: 5)
                .padding(.top, 12)
                .padding(.bottom, 16)

            Text("오늘 어디까지 읽었나요?")
                .font(.sketchBold(20))
                .foregroundColor(.ink)

            // 퍼센트
            HStack(alignment: .firstTextBaseline, spacing: 2) {
                Text("\(percent)")
                    .font(.sketchBold(52))
                    .foregroundColor(settings.accentColor)
                    .contentTransition(.numericText())
                    .animation(.easeOut(duration: 0.15), value: percent)
                Text("%")
                    .font(.sketchBold(28))
                    .foregroundColor(settings.accentColor)
            }
            .padding(.top, 8)

            SketchProgressBar(progress: progress, width: 260, lineWidth: 5)
                .padding(.bottom, 12)

            // 휠 피커
            HStack(spacing: 8) {
                Picker("Page", selection: $selectedPage) {
                    ForEach(
                        store.book.currentPage...max(store.book.currentPage, store.book.totalPages),
                        id: \.self
                    ) { n in
                        Text("\(n)").tag(n)
                    }
                }
                .pickerStyle(.wheel)
                .frame(width: 110, height: 160)
                .onChange(of: selectedPage) { _, _ in
                    UIImpactFeedbackGenerator(style: .light).impactOccurred()
                }

                Text("/ \(store.book.totalPages)쪽")
                    .font(.sketch(19))
                    .foregroundColor(.inkFaint)
            }

            // 한 줄 메모
            VStack(alignment: .leading, spacing: 8) {
                Text("한 줄 메모 (선택)")
                    .font(.sketchBold(15))
                    .foregroundColor(.inkSoft)

                TextField("오늘 읽은 내용을 한 줄로 남겨보세요", text: $store.inputMemo)
                    .font(.sketch(16))
                    .foregroundColor(.ink)
                    .tint(settings.accentColor)
                    .padding(12)
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color.ink.opacity(0.4), lineWidth: 1.4)
                    )
            }
            .padding(.horizontal, 24)
            .padding(.top, 8)

            Button {
                store.send(.updatePageConfirmed(selectedPage))
            } label: {
                Text("기록하기")
                    .font(.sketchBold(20))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 13)
                    .background(settings.accentColor)
                    .clipShape(RoundedRectangle(cornerRadius: 14))
            }
            .padding(.horizontal, 22)
            .padding(.top, 16)
            .padding(.bottom, 30)
        }
        .background(Color.paper)
        .presentationDetents([.large])
        .presentationDragIndicator(.hidden)
        .presentationBackground(Color.paper)
        .onAppear {
            selectedPage = max(store.book.currentPage, 1)
        }
    }
}

// MARK: - 완독 소감 시트
struct FinishedSheet: View {
    @Bindable var store: StoreOf<BookDetailFeature>
    @Shared(.settings) var settings: AppSettings
    @State private var stampVisible = false

    private var todayString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy. M. d"
        return formatter.string(from: Date())
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                Capsule()
                    .fill(Color.ink.opacity(0.2))
                    .frame(width: 44, height: 5)
                    .padding(.top, 12)

                // 책 표지 + 도장 오버레이
                ZStack {
                    BookCoverView(
                        seed: store.book.seed,
                        coverURL: store.book.coverURL,
                        width: 100,
                        height: 132,
                        tilt: false
                    )

                    FinishStamp(date: todayString)
                        .scaleEffect(stampVisible ? 1 : 2.4)
                        .rotationEffect(.degrees(stampVisible ? -14 : -6))
                        .opacity(stampVisible ? 1 : 0)
                        .offset(x: 44, y: -44)
                }
                .frame(width: 100, height: 132)  // 책 표지 크기로 고정
                .padding(.top, 16)

                Text("완독을 축하해요!")
                    .font(.sketchBold(24))
                    .foregroundColor(.ink)

                Text(store.book.title)
                    .font(.sketch(16))
                    .foregroundColor(.inkFaint)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 24)

                VStack(alignment: .leading, spacing: 8) {
                    Text("완독 소감 (선택)")
                        .font(.sketchBold(15))
                        .foregroundColor(.inkSoft)

                    TextField("책을 다 읽고 난 소감을 남겨보세요", text: $store.finishedMemo)
                        .font(.sketch(16))
                        .foregroundColor(.ink)
                        .tint(settings.accentColor)
                        .padding(12)
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color.ink.opacity(0.4), lineWidth: 1.4)
                        )
                }
                .padding(.horizontal, 24)

                Button {
                    store.send(.finishedConfirmed)
                } label: {
                    Text("소감 남기기")
                        .font(.sketchBold(20))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 13)
                        .background(settings.accentColor)
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                }
                .padding(.horizontal, 22)
                .padding(.bottom, 30)
            }
        }
        .background(Color.paper)
        .presentationDetents([.large])
        .presentationDragIndicator(.hidden)
        .presentationBackground(Color.paper)
        .onAppear {
            withAnimation(.spring(response: 0.4, dampingFraction: 0.55).delay(0.45)) {
                stampVisible = true
            }
            UINotificationFeedbackGenerator().notificationOccurred(.success)
        }
    }
}

// MARK: - 완독 도장
struct FinishStamp: View {
    var date: String
    @Shared(.settings) var settings: AppSettings

    var body: some View {
        ZStack {
            Circle()
                .stroke(settings.accentColor, lineWidth: 5)
                .frame(width: 110, height: 110)
            Circle()
                .stroke(settings.accentColor, style: StrokeStyle(lineWidth: 1.8, dash: [4, 5]))
                .frame(width: 92, height: 92)
            VStack(spacing: 3) {
                Text("완독")
                    .font(.sketchBold(30))
                Text(date)
                    .font(.sketchBold(15))
            }
            .foregroundColor(settings.accentColor)
        }
        .opacity(0.9)
    }
}

#Preview {
    NavigationStack {
        BookDetailView(
            store: Store(
                initialState: BookDetailFeature.State(
                    book: Book.samples[0]
                )
            ) {
                BookDetailFeature()
            }
        )
    }
}
