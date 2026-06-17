//
//  LoginView.swift
//  Bookmark-Dev
//
//  Created by wodnd on 6/12/26.
//

import SwiftUI
import ComposableArchitecture
import AuthenticationServices
import FirebaseAuth

struct LoginView: View {
    @Bindable var store: StoreOf<LoginFeature>
    @Shared(.settings) var settings: AppSettings
    @State private var currentNonce: String = ""

    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                Spacer()

                Image(settings.iconName)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 88)

                Text("책갈피")
                    .font(.sketchBold(36))
                    .foregroundColor(.ink)
                    .padding(.top, 14)
                    .padding(.bottom, 10)

                WavyLine(width: 76, color: settings.accentColor, lineWidth: 2.4)

                Text("로그인 하고 친구와 함께 읽어요")
                    .font(.sketch(17))
                    .foregroundColor(.inkSoft)
                    .padding(.top, 8)

                Spacer()

                VStack(spacing: 12) {
                    SignInWithAppleButton(.continue) { request in
                        // 1. Apple 다이얼로그 띄우기 전 네트워크 체크
                        // (LoginFeature.appleLoginTapped에서 처리)
                        let nonce = randomNonceString()
                        currentNonce = nonce
                        store.send(.appleLoginTapped)
                        request.requestedScopes = []
                        request.nonce = sha256(nonce)
                    } onCompletion: { result in
                        switch result {
                        case .success(let authorization):
                            if let credential = authorization.credential as? ASAuthorizationAppleIDCredential,
                               let identityToken = credential.identityToken,
                               let tokenString = String(data: identityToken, encoding: .utf8) {

                                let firebaseCredential = OAuthProvider.credential(
                                    providerID: .apple,
                                    idToken: tokenString,
                                    rawNonce: currentNonce
                                )

                                // 2. Firebase signIn 직전 네트워크 체크
                                guard NetworkMonitor.shared.isConnected else {
                                    store.send(.appleLoginCompleted(.failure(.networkError)))
                                    return
                                }

                                Auth.auth().signIn(with: firebaseCredential) { authResult, error in
                                    if let error = error as NSError? {
                                        if error.code == NSURLErrorTimedOut {
                                            store.send(.appleLoginCompleted(.failure(.timeout)))
                                        } else if error.code == NSURLErrorNotConnectedToInternet {
                                            store.send(.appleLoginCompleted(.failure(.networkError)))
                                        } else {
                                            store.send(.appleLoginCompleted(.failure(.unknown)))
                                        }
                                    } else if let uid = authResult?.user.uid {
                                        store.send(.appleLoginCompleted(.success(uid)))   
                                    }
                                }
                            } else {
                                store.send(.appleLoginCompleted(.failure(.unknown)))
                            }
                        case .failure(let error):
                            // 사용자가 직접 취소한 경우
                            let asError = error as? ASAuthorizationError
                            if asError?.code == .canceled {
                                store.send(.appleLoginCompleted(.failure(.cancelled)))
                            } else {
                                store.send(.appleLoginCompleted(.failure(.unknown)))
                            }
                        }
                    }
                    .signInWithAppleButtonStyle(.black)
                    .frame(height: 52)

                    Text("계속하면 이용약관에 동의하는 것으로 간주해요")
                        .font(.sketch(13))
                        .foregroundColor(.inkFaint)
                }
                .padding(.horizontal, 14)
                .padding(.bottom, 44)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.paper)
            .blur(radius: store.isLoading ? 4 : 0)
            .animation(.easeInOut(duration: 0.2), value: store.isLoading)

            if store.isLoading {
                LoadingView()
                    .transition(.opacity)
            }

            if let message = store.toastMessage {
                VStack {
                    Spacer()
                    ToastView(message: message)
                        .padding(.bottom, 60)
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                        .onAppear {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                                store.send(.toastDismissed)
                            }
                        }
                }
                .animation(.spring(response: 0.35, dampingFraction: 0.7), value: store.toastMessage)
            }
        }
        .animation(.easeInOut(duration: 0.2), value: store.isLoading)
    }
}

#Preview {
    LoginView(
        store: Store(initialState: LoginFeature.State(), reducer: {
            LoginFeature()
        })
    )
}
