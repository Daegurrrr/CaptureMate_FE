//
//  HomeView.swift
//  CaptureMate
//
//  Created by 허채윤 on 4/11/26.
//

import SwiftUI

struct HomeView: View {
    @StateObject private var viewModel = HomeViewModel()
    
    let actions: [RecommendedAction] = [
        RecommendedAction(
            icon: "hourglass",
            title: "곧 만료되는 쿠폰",
            subtitle: "<스타벅스> 아메리카노 → D - 2"
        ),
        RecommendedAction(
            icon: "mappin",
            title: "감지된 장소",
            subtitle: "애니언 성수"
        ),
        RecommendedAction(
            icon: "calendar",
            title: "감지된 일정",
            subtitle: "신사 몬차치 팝업 → ~4월 30일"
        )
    ]
    
    var body: some View {
        let summary = CaptureSummary(
            totalCount: viewModel.todayScreenshotCount,
            placeCount: 0,
            couponCount: 0,
            otherCount: 0
        )

        return VStack(spacing: 0) {
            HomeHeaderView()

            VStack(spacing: 0) {
                SearchBarView()

                Spacer()
                    .frame(height: 16)
            }
            .background(Color.white)

            ScrollView {
                VStack(alignment: .leading, spacing: 18) {
                    Text("오늘 감지된 캡쳐")
                        .font(.system(size: 20, weight: .bold))
                        .padding(.horizontal, 16)
                        .padding(.top, 10)

                    TodayCaptureSummaryCard(summary: summary)
                        .padding(.horizontal, 16)

                    Text("추천 액션")
                        .font(.system(size: 20, weight: .bold))
                        .padding(.horizontal, 16)

                    RecommendedActionCard(actions: actions)
                        .padding(.horizontal, 16)

                    Text("최근 캡쳐 모아보기")
                        .font(.system(size: 20, weight: .bold))
                        .padding(.horizontal, 16)

                    RecentCaptureSection(images: viewModel.recentScreenshots)
                        .padding(.horizontal, 16)

                    Spacer(minLength: 20)
                }
                .padding(.top, 10)
            }
            .background(Color(red: 245/255, green: 244/255, blue: 249/255))
        }
        .background(Color.white)
        .onAppear {
            viewModel.loadRecentScreenshots()
            viewModel.loadTodayScreenshotCount()
        }
        .onReceive(
            NotificationCenter.default.publisher(
                for: UIApplication.willEnterForegroundNotification
            )
        ) { _ in
            viewModel.loadRecentScreenshots()
            viewModel.loadTodayScreenshotCount()
        }
        .onReceive(
            NotificationCenter.default.publisher(
                for: NSNotification.Name("ScreenshotDataUpdated")
            )
        ) { _ in
            viewModel.loadRecentScreenshots()
            viewModel.loadTodayScreenshotCount()
        }
    }
    
}
