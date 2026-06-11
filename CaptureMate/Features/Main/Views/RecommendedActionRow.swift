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

    @State private var offsetX: CGFloat = 0
    private let deleteWidth: CGFloat = 72

    var body: some View {
        ZStack(alignment: .trailing) {
            Button {
                onDelete()
                withAnimation {
                    offsetX = 0
                }
            } label: {
                Image(systemName: "trash")
                    .foregroundColor(.white)
                    .frame(width: deleteWidth)
                    .frame(maxHeight: .infinity)
                    .background(Color.red)
            }
            .offset(x: deleteWidth + offsetX)

            rowContent
                .offset(x: offsetX)
                .gesture(
                    DragGesture()
                        .onChanged { value in
                            if value.translation.width < 0 {
                                offsetX = max(value.translation.width, -deleteWidth)
                            }
                        }
                        .onEnded { value in
                            withAnimation(.spring()) {
                                offsetX = value.translation.width < -40 ? -deleteWidth : 0
                            }
                        }
                )
        }
        .clipped()
    }

    private var rowContent: some View {
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
        .background(Color.white)
        .contentShape(Rectangle())
        .onTapGesture {
            if offsetX == 0 {
                onTap()
            } else {
                withAnimation {
                    offsetX = 0
                }
            }
        }
    }
}
