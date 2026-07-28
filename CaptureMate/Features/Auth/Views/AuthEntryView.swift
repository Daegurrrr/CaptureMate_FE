//
//  AuthEntryView.swift
//  CaptureMate
//
//  Created by 허채윤 on 4/11/26.
//

import SwiftUI

struct AuthEntryView: View {
    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                Spacer()
                
                Text("CaptureMate")
                    .font(.system(size: 32, weight: .bold))
                
                Text("로그인 또는 회원가입을 진행해주세요.")
                    .font(.system(size: 16))
                    .foregroundColor(.gray)
                
                Spacer()
                
                NavigationLink {
                    LoginView()
                } label: {
                    Text("로그인")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
                        .background(Color.blue)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                }
                
                NavigationLink {
                    SignUpView()
                } label: {
                    Text("새로 시작하기")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.blue)
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
                        .background(Color.white)
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(Color.blue, lineWidth: 1.5)
                        )
                }
                
                Spacer().frame(height: 40)
            }
            .padding(.horizontal, 24)
            .navigationBarBackButtonHidden(true)
        }
    }
}
