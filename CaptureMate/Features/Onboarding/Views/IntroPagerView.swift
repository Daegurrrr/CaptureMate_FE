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
    @State private var maxSeenPage = 0

    private let pages: [IntroPage] = [
        IntroPage(
            imageName: "onboarding_capture",
            title: "필요한 순간을\n먼저 캡쳐하세요",
            subtitle: ""
        ),
        IntroPage(
            imageName: "onboarding_category",
            title: "캡쳐는 카테고리별로\n자동 정리돼요",
            subtitle: ""
        ),
        IntroPage(
            imageName: "onboarding_action",
            title: "추천 액션을 누르면\n바로 원하는 곳으로 이동해요",
            subtitle: ""
        ),
        IntroPage(
            imageName: "onboarding_results",
            title: "장소, 쇼핑, 일정, 메모까지\n필요한 정보만 보여드려요",
            subtitle: ""
        )
    ]

    private var canStart: Bool {
        maxSeenPage >= pages.count - 1
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                Spacer().frame(height: 18)
                
                TabView(selection: $currentPage) {
                    ForEach(Array(pages.enumerated()), id: \.offset) { index, page in
                        IntroPageView(page: page)
                            .tag(index)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .frame(maxWidth: .infinity)
                .frame(height: 620)
                .onChange(of: currentPage) { _, newPage in
                    maxSeenPage = max(maxSeenPage, newPage)
                }

                HStack(spacing: 10) {
                    ForEach(0..<pages.count, id: \.self) { index in
                        Circle()
                            .fill(index == currentPage ? Color.gray : Color.gray.opacity(0.3))
                            .frame(width: 10, height: 10)
                    }
                }
                .padding(.top, 12)

                Button {
                    guard canStart else {
                        return
                    }

                    session.completeIntro()
                } label: {
                    Text("시작하기")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .background(canStart ? Color.blue : Color.gray.opacity(0.35))
                        .clipShape(RoundedRectangle(cornerRadius: 30))
                }
                .disabled(!canStart)
                .buttonStyle(.plain)
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
