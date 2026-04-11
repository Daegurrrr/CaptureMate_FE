//
//  TodayCapture.swift
//  CaptureMate
//
//  Created by 허채윤 on 4/11/26.
//

import SwiftUI

struct TodayCaptureSummaryCard: View {
    let summary: CaptureSummary

    var body: some View {
        VStack(spacing: 14) {
            HStack(alignment: .top) {
                HStack(alignment: .firstTextBaseline, spacing: 2) {
                    Text("\(summary.totalCount)")
                        .font(.system(size: 36, weight: .bold))
                    Text("개")
                        .font(.system(size: 18, weight: .bold))
                }

                Spacer()

                Image(systemName: "photo.on.rectangle.angled")
                    .font(.system(size: 30))
                    .foregroundColor(.orange)
            }

            Divider()

            HStack(spacing: 12) {
                SummaryMiniCard(title: "장소", count: summary.placeCount, bgColor: Color(red: 231/255, green: 236/255, blue: 250/255))
                SummaryMiniCard(title: "쿠폰", count: summary.couponCount, bgColor: Color(red: 246/255, green: 237/255, blue: 232/255))
                SummaryMiniCard(title: "기타", count: summary.otherCount, bgColor: Color(red: 234/255, green: 243/255, blue: 238/255))
            }
        }
        .padding(16)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}

struct SummaryMiniCard: View {
    let title: String
    let count: Int
    let bgColor: Color

    var body: some View {
        VStack(spacing: 6) {
            Text(title)
                .font(.system(size: 14))
                .foregroundColor(.gray)

            Text("\(count)")
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(.black)
        }
        .frame(maxWidth: .infinity)
        .frame(height: 78)
        .background(bgColor)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}
