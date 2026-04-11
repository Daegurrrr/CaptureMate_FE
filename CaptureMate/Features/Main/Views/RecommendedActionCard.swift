//
//  Recommend.swift
//  CaptureMate
//
//  Created by 허채윤 on 4/11/26.
//

import SwiftUI

struct RecommendedActionCard: View {
    let actions: [RecommendedAction]

    var body: some View {
        List {
            ForEach(actions.indices, id: \.self) { index in
                HStack(spacing: 12) {
                    Image(systemName: actions[index].icon)
                        .frame(width: 20)
                        .foregroundColor(.brown)

                    VStack(alignment: .leading, spacing: 4) {
                        Text(actions[index].title)
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.black)

                        Text(actions[index].subtitle)
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
                    .buttonStyle(.plain)
                }
                .listRowInsets(EdgeInsets(top: 12, leading: 14, bottom: 12, trailing: 14))
                .listRowSeparator(index == 0 ? .hidden : .visible, edges: .top)
                .listRowBackground(Color.white)
                .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                    Button {
                        print("삭제 예정: \(actions[index].title)")
                    } label: {
                        Image(systemName: "trash")
                    }
                    .tint(.red)
                }
            }
        }
        .listStyle(.plain)
        .scrollDisabled(true)
        .scrollContentBackground(.hidden)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .frame(height: 192)
    }
}
