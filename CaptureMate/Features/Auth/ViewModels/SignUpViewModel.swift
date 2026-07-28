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
            isRegisterSuccess = false

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

        if message.contains("72 bytes") {
            return "비밀번호는 최대 72바이트까지 입력할 수 있어요."
        }

        if message.contains("already") ||
            message.contains("duplicate") ||
            message.contains("exists") ||
            message.contains("이미") {
            return "이미 사용 중인 아이디 또는 이메일입니다."
        }

        if message.contains("email") ||
            message.contains("Email") ||
            message.contains("이메일") {
            return "이메일 형식을 다시 확인해주세요."
        }

        if message.contains("network") ||
            message.contains("timed out") ||
            message.contains("Internet") ||
            message.contains("offline") {
            return "네트워크 연결을 확인해주세요."
        }

        if message.contains("응답 데이터를 처리하지 못했습니다") {
            return "회원가입 응답 처리 중 문제가 발생했습니다."
        }

        return message
    }
}
