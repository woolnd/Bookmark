//
//  SharedState.swift
//  Bookmark
//
//  Created by wodnd on 6/12/26.
//

import Foundation
import ComposableArchitecture

extension SharedReaderKey where Self == AppStorageKey<Bool>.Default {
    static var isOnboared: Self {
        Self[.appStorage("bk_onboarded"), default: false]
    }
}

extension SharedReaderKey where Self == AppStorageKey<String>.Default {
    static var nickname: Self {
        Self[.appStorage("bk_nickname"), default: ""]
    }
}
