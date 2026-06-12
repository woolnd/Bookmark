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

                            Auth.auth().signIn(with: firebaseCredential) { authResult, error in
                                if let error = error {
                                    print("Firebase 로그인 실패:", error)
                                    store.send(.loginFailed)
                                } else if let uid = authResult?.user.uid {
                                    store.send(.loginSucceeded(uid: uid))
                                }
                            }
                        } else {
                            store.send(.appleLoginCompleted(.failure(.unknown)))
                        }
                    case .failure:
                        store.send(.appleLoginCompleted(.failure(.unknown)))
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
    }
}

#Preview {
    LoginView(
        store: Store(initialState: LoginFeature.State(), reducer: {
            LoginFeature()
        })
    )
}
