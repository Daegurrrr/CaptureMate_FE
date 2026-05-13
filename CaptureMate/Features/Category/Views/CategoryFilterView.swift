//
//  CategoryFilterView.swift
//  CaptureMate
//
//  Created by 허채윤 on 5/13/26.
//

import SwiftUI

struct CategoryFilterView: View {
    @Binding var selectedCategory: CaptureCategory

    var body: some View {
        HStack(spacing: 8) {
            ForEach(CaptureCategory.allCases) { category in
                Button {
                    selectedCategory = category
                } label: {
                    Text(category.displayTitle)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(selectedCategory == category ? .white : .black)
                        .padding(.horizontal, 16)
                        .frame(height: 34)
                        .background(
                            Capsule()
                                .fill(selectedCategory == category ? Color.black : Color.white)
                        )
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.top, 14)
        .padding(.bottom, 10)
    }
}

