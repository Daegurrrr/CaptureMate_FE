//
//  Recommend.swift
//  CaptureMate
//
//  Created by 허채윤 on 4/11/26.
//

import SwiftUI

struct RecommendedActionRow: View {
    let action: RecommendedAction
    let onDelete: () -> Void

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: action.icon)
                .frame(width: 22)
                .foregroundColor(.brown)

            VStack(alignment: .leading, spacing: 4) {
                Text(action.title)
                    .font(.system(size: 16, weight: .medium))

                Text(action.subtitle)
                    .font(.system(size: 14))
                    .foregroundColor(.gray)
            }

            Spacer()

            Button {
                print("더보기")
            } label: {
                Image(systemName: "ellipsis")
                    .foregroundColor(.gray)
                    .frame(width: 32, height: 32)
                    .background(Color(.systemGray6))
                    .clipShape(Circle())
            }
        }
        .padding(.vertical, 14)
        .padding(.horizontal, 14)

        // ⭐ 여기서 스와이프 기능 추가
        .swipeActions(edge: .trailing, allowsFullSwipe: false) {

            Button {
                onDelete()
            } label: {
                Image(systemName: "trash")
            }
            .tint(.red)

        }
    }
}
