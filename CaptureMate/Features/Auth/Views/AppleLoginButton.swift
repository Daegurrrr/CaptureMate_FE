//
//  AppleLoginButton.swift
//  CaptureMate
//
//  Created by 허채윤 on 5/10/26.
//

import SwiftUI
import AuthenticationServices

struct AppleLoginButton: View {

    let onSuccess: (String) -> Void

    var body: some View {
        SignInWithAppleButton(
            .signIn,
            onRequest: { request in
                request.requestedScopes = [.fullName, .email]
            },
            onCompletion: { result in
                switch result {
                case .success(let authResults):

                    guard let credential = authResults.credential as? ASAuthorizationAppleIDCredential,
                          let tokenData = credential.identityToken,
                          let tokenString = String(data: tokenData, encoding: .utf8)
                    else {
                        return
                    }

                    onSuccess(tokenString)

                case .failure(let error):
                    print(error.localizedDescription)
                }
            }
        )
        .signInWithAppleButtonStyle(.black)
        .frame(height: 50)
    }
}
