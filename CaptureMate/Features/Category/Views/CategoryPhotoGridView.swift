//
//  CategoryPhotoGridView.swift
//  CaptureMate
//
//  Created by 허채윤 on 5/13/26.
//

import SwiftUI

struct CategoryPhotoGridView: View {
    // 실제 분류된 후 이미지 보여줄때 사용하는 코드
    // let items: [CategoryCaptureItem]
    
    // 임시로 내 갤러리 모든 사진 보여주는 코드
    let items: [CategoryPhotoItem]

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
            LazyVGrid(columns: columns, spacing: 12) {
                ForEach(items) { item in
                    Image(uiImage: item.image)
                        .resizable()
                        .scaledToFit()
                        .clipShape(RoundedRectangle(cornerRadius: 14))
//                    Image(item.imageName)
//                        .resizable()
//                        .scaledToFill()
//                        .frame(height: 110)
//                        .clipShape(RoundedRectangle(cornerRadius: 14))
//                        .clipped()
                }
            }
        }
    }
}
