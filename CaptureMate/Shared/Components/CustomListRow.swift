//
//  CustomListRow.swift
//  CaptureMate
//
//  Created by 허채윤 on 4/6/26.
//

import SwiftUI

struct CaptureListRow: View {

    let item: ScreenshotItem

    var body: some View {

        HStack(spacing: 14) {

            Image(systemName: item.category.icon)
                .font(.title2)
                .foregroundStyle(item.category.tint)
                .frame(width: 42, height: 42)
                .background(item.category.tint.opacity(0.12))
                .clipShape(RoundedRectangle(cornerRadius: 12))

            VStack(alignment: .leading, spacing: 4) {

                Text(item.title ?? "제목 없음")
                    .fontWeight(.medium)

                Text(item.summary ?? "제목 없음")
                    .font(.caption)
                    .foregroundStyle(.secondary)

            }

        }
        .padding(.vertical, 6)

    }

}
