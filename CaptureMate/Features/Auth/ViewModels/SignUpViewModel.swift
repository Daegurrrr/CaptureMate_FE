//
//  SignUpViewModel.swift
//  CaptureMate
//
//  Created by 허채윤 on 5/13/26.
//

import Foundation

@MainActor
final class SignUpViewModel: ObservableObject {
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var isRegisterSuccess = false

    private let authService = AuthService()

    func register(
        loginId: String,
        password: String,
        username: String,
        email: String
    ) {
        Task {
            isLoading = true
            errorMessage = nil

            do {
                try await authService.register(
                    loginId: loginId,
                    password: password,
                    username: username,
                    email: email
                )

                print("회원가입 성공")
                isRegisterSuccess = true
            } catch {
                print("회원가입 실패:", error.localizedDescription)
                errorMessage = convertRegisterErrorMessage(error)
            }

            isLoading = false
        }
    }
    
    private func convertRegisterErrorMessage(_ error: Error) -> String {
        let message = error.localizedDescription

        if message.contains("password cannot be longer than 72 bytes") {
            return "비밀번호는 최대 72바이트까지 입력할 수 있어요."
        }

        if message.contains("already") ||
            message.contains("duplicate") ||
            message.contains("exists") {
            return "이미 사용 중인 아이디 또는 이메일입니다."
        }

        if message.contains("email") {
            return "이메일 형식을 다시 확인해주세요."
        }

        return "회원가입 중 오류가 발생했습니다. 입력 정보를 다시 확인해주세요."
    }
}
