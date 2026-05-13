//
//  CategoryView.swift
//  CaptureMate
//
//  Created by 허채윤 on 4/6/26.
//

import SwiftUI

struct CategoryView: View {
    @StateObject private var viewModel = CategoryViewModel()
    @State private var selectedPhoto: CategoryPhotoItem?

    var body: some View {
        VStack(spacing: 0) {
            AppHeaderView(title: "Category")

            SearchBarView(searchText: $viewModel.searchText)
                .padding(.horizontal, 14)
                .padding(.bottom, 10)

            Divider()

            VStack(spacing: 0) {
                CategoryFilterView(selectedCategory: $viewModel.selectedCategory)

                ScrollView(showsIndicators: false) {
                    // 분류 모델로 분류 후 실제 사진 필터링할때 사용
//                    CategoryPhotoGridView(items: viewModel.filteredItems)
                    
                    // 임시로 필터링 없이 전체 사진 보여줌
                    CategoryPhotoGridView(
                        items: viewModel.photos,
                        selectedPhoto: $selectedPhoto
                    )
                    .fullScreenCover(item: $selectedPhoto) { photo in
                        PhotoDetailView(photo: photo)
                    }
                        .padding(.leading, 16)
                        .padding(.top, 20)
                        .padding(.horizontal, 16)
                        .padding(.bottom, 100)
                }
                .onAppear {
                    viewModel.requestPhotoPermissionAndLoad()
                }
            }
            .background(Color(red: 0.97, green: 0.96, blue: 1.0))
        }
        .background(Color.white)
    }
}
