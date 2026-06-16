//
//  MockData.swift
//  Bookmark
//
//  Created by wodnd on 6/16/26.
//

import Foundation

extension Book {
    static let samples: [Book] = [
        Book(id: "b1", title: "사피엔스", author: "유발 하라리", totalPages: 636, currentPage: 394,
             note: "농업혁명 파트 흥미진진", seed: 4, coverURL: nil, loggedToday: true,
             logs: [
                ReadingLog(date: "오늘", page: 394, note: "농업혁명 파트 흥미진진"),
                ReadingLog(date: "6월 8일", page: 351, note: "인지혁명 챕터 다시 읽음"),
             ]),
        Book(id: "b2", title: "달러구트 꿈 백화점", author: "이미예", totalPages: 300, currentPage: 102,
             note: "", seed: 1, coverURL: nil,
             logs: [
                ReadingLog(date: "6월 8일", page: 102, note: ""),
                ReadingLog(date: "6월 4일", page: 60, note: "페니와 아삭의 세계관 귀엽다"),
             ]),
        Book(id: "b3", title: "아주 작은 습관의 힘", author: "제임스 클리어", totalPages: 320, currentPage: 288,
             note: "1% 복리의 힘", seed: 6, coverURL: nil,
             logs: [
                ReadingLog(date: "6월 9일", page: 288, note: "1% 복리의 힘"),
             ]),
        Book(id: "b4", title: "나미야 잡화점의 기적", author: "히가시노 게이고", totalPages: 456, currentPage: 41,
             note: "", seed: 2, coverURL: nil,
             logs: [ReadingLog(date: "6월 3일", page: 41, note: "")]),
    ]
}

extension Friend {
    static let samples: [Friend] = [
        Friend(id: "f1", name: "민준", initial: "민", code: "MINJ-3K9P", when: "12분 전",
               note: "같이 읽으니 동기부여 된다",
               reading: [
                   ReadingBook(title: "사피엔스", author: "유발 하라리", totalPages: 636, currentPage: 503, seed: 4,
                       logs: [ReadingLog(date: "오늘", page: 503, note: "제국의 비전 챕터, 생각할 게 많다")]),
                   ReadingBook(title: "코스모스", author: "칼 세이건", totalPages: 560, currentPage: 120, seed: 5,
                       logs: [ReadingLog(date: "6월 5일", page: 120, note: "두 번째 읽는 중. 여전히 좋다")]),
               ],
               finished: [
                   FinishedBook(title: "총, 균, 쇠", author: "재레드 다이아몬드", totalPages: 736, seed: 3,
                                rating: 5, review: "문명의 운명을 가른 건 지리였다"),
               ]),
        Friend(id: "f2", name: "서연", initial: "서", code: "SEOY-7T2M", when: "1시간 전",
               note: "결말 충격…",
               reading: [
                   ReadingBook(title: "미드나잇 라이브러리", author: "매트 헤이그", totalPages: 412, currentPage: 330, seed: 0,
                       logs: [ReadingLog(date: "1시간 전", page: 330, note: "결말 충격…")]),
               ],
               finished: [
                   FinishedBook(title: "불편한 편의점", author: "김호연", totalPages: 268, seed: 7,
                                rating: 5, review: "따뜻하다. 독고씨 최고"),
               ]),
        Friend(id: "f3", name: "도윤", initial: "도", code: "DOYU-1A8Q", when: "어제", note: "",
               reading: [
                   ReadingBook(title: "불편한 편의점", author: "김호연", totalPages: 268, currentPage: 89, seed: 7,
                       logs: [ReadingLog(date: "6월 4일", page: 30, note: "서연이 추천으로 시작")]),
               ],
               finished: []),
    ]
}
