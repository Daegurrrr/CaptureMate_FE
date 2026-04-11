//
//  IntroPageView.swift
//  CaptureMate
//
//  Created by 허채윤 on 4/11/26.
//

import SwiftUI

struct IntroPagerView: View {
    @EnvironmentObject private var session: AppSession
    @State private var currentPage = 0

    private let pages: [IntroPage] = [
        IntroPage(
            imageName: "intro_home",
            title: "스크린샷 찍고\n분석해서 정보 저장 빠르게",
            subtitle: ""
        ),
        IntroPage(
            imageName: "intro_map",
            title: "장소\n자동 분류하고 저장까지!",
            subtitle: ""
        ),
        IntroPage(
            imageName: "intro_search",
            title: "지금 바로 시작해보세요!",
            subtitle: ""
        )
    ]

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                Button {
                } label: {
                    Text("사용 가이드 보기")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.black)
                        .padding(.top, 20)
                }
                
                TabView(selection: $currentPage) {
                    ForEach(Array(pages.enumerated()), id: \.offset) { index, page in
                        IntroPageView(page: page)
                            .tag(index)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .frame(maxWidth: .infinity)
                .frame(height: 620)

                HStack(spacing: 10) {
                    ForEach(0..<pages.count, id: \.self) { index in
                        Circle()
                            .fill(index == currentPage ? Color.gray : Color.gray.opacity(0.3))
                            .frame(width: 10, height: 10)
                    }
                }
                .padding(.top, 12)

                HStack(spacing: 16) {
                    NavigationLink(destination: LoginView()) {
                        Text("로그인")
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundColor(.blue)
                            .frame(maxWidth: .infinity)
                            .frame(height: 50)
                            .background(Color.white)
                            .overlay(
                                RoundedRectangle(cornerRadius: 30)
                                    .stroke(Color.blue, lineWidth: 0.5)
                            )
                    }
                    .buttonStyle(.plain)

                    NavigationLink(destination: SignUpView()) {
                        Text("새로 시작하기")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 50)
                            .background(Color.blue)
                            .clipShape(RoundedRectangle(cornerRadius: 30))
                    }
                    .buttonStyle(.plain)
                }
                .padding(.horizontal, 24)
                .padding(.top, 28)

                Spacer(minLength: 0)
            }
            .background(Color.white)
            .ignoresSafeArea(.container, edges: .bottom)
        }
    }
}

#Preview {
    IntroPagerView()
        .environmentObject(AppSession())
}
