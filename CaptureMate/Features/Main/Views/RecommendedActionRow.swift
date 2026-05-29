//
//  RecommendedActionRow.swift
//  CaptureMate
//
//  Created by 허채윤 on 4/11/26.
//

import SwiftUI

struct RecommendedActionRow: View {
    let action: RecommendedAction
    let onTap: () -> Void
    let onDelete: () -> Void

    var body: some View {
        Button {
            onTap()
        } label: {

            HStack(spacing: 12) {

                Image(systemName: action.icon)
                    .frame(width: 20)
                    .foregroundColor(.brown)

                VStack(alignment: .leading, spacing: 4) {

                    Text(action.title)
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.black)

                    if let subtitle = action.subtitle {
                        Text(subtitle)
                            .font(.system(size: 14))
                            .foregroundColor(.gray)
                    }
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .foregroundColor(.gray)
            }
            .padding(.vertical, 14)
            .padding(.horizontal, 14)
        }
        .buttonStyle(.plain)

        .swipeActions(
            edge: .trailing,
            allowsFullSwipe: false
        ) {

            Button {
                onDelete()
            } label: {
                Image(systemName: "trash")
            }
            .tint(.red)
        }
    }
}
