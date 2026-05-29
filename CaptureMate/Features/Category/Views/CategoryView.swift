//
//  CategoryView.swift
//  CaptureMate
//
//  Created by 허채윤 on 4/6/26.
//

import SwiftUI
import SwiftData

struct CategoryView: View {
    @Environment(\.modelContext) private var modelContext

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
                    CategoryPhotoGridView(
                        items: viewModel.filteredItems,
                        selectedPhoto: $selectedPhoto
                    )
                    .padding(.top, 20)
                    .padding(.horizontal, 16)
                    .padding(.bottom, 100)
                }
                .onAppear {
                    viewModel.requestPhotoPermissionAndLoad(
                        modelContext: modelContext
                    )
                }
            }
            .background(Color(red: 0.97, green: 0.96, blue: 1.0))
        }
        .background(Color.white)
        .fullScreenCover(item: $selectedPhoto) { photo in
            PhotoDetailView(photo: photo)
        }
    }
}
