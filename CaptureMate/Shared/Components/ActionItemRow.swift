//
//  ActionItemRow.swift
//  CaptureMate
//
//  Created by 허채윤 on 4/6/26.
//

import SwiftUI

struct ActionItemRow: View {
    let icon: String
    let title: String
    let subtitle: String

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 20))
                .frame(width: 28)
                .foregroundColor(.black)

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 16, weight: .semibold))

                Text(subtitle)
                    .font(.system(size: 14))
                    .foregroundColor(.gray)
            }

            Spacer()

            Circle()
                .fill(Color(.systemGray6))
                .frame(width: 34, height: 34)
                .overlay(
                    Image(systemName: "ellipsis")
                        .foregroundColor(.gray)
                )
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 14)
    }
}
