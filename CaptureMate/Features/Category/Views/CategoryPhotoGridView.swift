//
//  CategoryPhotoGridView.swift
//  CaptureMate
//
//  Created by 허채윤 on 5/13/26.
//

import SwiftUI

struct CategoryPhotoGridView: View {
    let items: [CategoryPhotoItem]
    @Binding var selectedPhoto: CategoryPhotoItem?

    private let columns = [
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12)
    ]

    var body: some View {
        if items.isEmpty {
            VStack(spacing: 8) {
                Text("저장된 캡쳐가 없어요")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.gray)

                Text("갤러리에서 불러온 캡쳐가 여기에 표시돼요")
                    .font(.system(size: 13))
                    .foregroundColor(.gray)
            }
            .frame(maxWidth: .infinity)
            .padding(.top, 80)
        } else {
            LazyVGrid(columns: columns, alignment: .center, spacing: 12) {
                ForEach(items) { item in
                    Image(uiImage: item.image)
                        .resizable()
                        .scaledToFill()
                        .frame(height: 110)
                        .frame(maxWidth: .infinity)
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                        .clipped()
                        .onTapGesture {
                            selectedPhoto = item
                        }
                }
            }
        }
    }
}
