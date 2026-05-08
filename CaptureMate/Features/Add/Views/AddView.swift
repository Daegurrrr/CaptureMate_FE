//
//  AddView.swift
//  CaptureMate
//
//  Created by 허채윤 on 4/6/26.
//

import SwiftUI
import Photos

struct AddView: View {
    @StateObject private var viewModel = AddViewModel()

    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 20) {
                if viewModel.isLoading {
                    ProgressView("캡쳐 사진을 불러오는 중...")
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    ScrollView {
                        VStack(alignment: .leading, spacing: 28) {
                            if !viewModel.newScreenshots.isEmpty {
                                newScreenshotSection
                            }

                            allScreenshotSection
                        }
                        .padding()
                    }
                }
            }
            .navigationTitle("캡쳐 추가")
            .onAppear {
                viewModel.requestPhotoPermissionAndLoad()
            }
            .confirmationDialog(
                "언제부터 캡쳐를 가져올까요?",
                isPresented: $viewModel.showDateFilterSheet,
                titleVisibility: .visible
            ) {
                Button("오늘") {
                    let date = Calendar.current.startOfDay(for: Date())
                    viewModel.selectStartDate(date)
                }

                Button("3일 전부터") {
                    let date = Calendar.current.date(
                        byAdding: .day,
                        value: -3,
                        to: Date()
                    ) ?? Date()

                    viewModel.selectStartDate(date)
                }

                Button("일주일 전부터") {
                    let date = Calendar.current.date(
                        byAdding: .day,
                        value: -7,
                        to: Date()
                    ) ?? Date()

                    viewModel.selectStartDate(date)
                }

                Button("한 달 전부터") {
                    let date = Calendar.current.date(
                        byAdding: .month,
                        value: -1,
                        to: Date()
                    ) ?? Date()

                    viewModel.selectStartDate(date)
                }

                Button("취소", role: .cancel) { }
            }
        }
    }

    private var newScreenshotSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("새로 감지된 캡쳐")
                .font(.headline)

            Text("방금 추가된 캡쳐를 먼저 확인해보세요.")
                .font(.subheadline)
                .foregroundStyle(.secondary)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(viewModel.newScreenshots) { photo in
                        screenshotCard(photo: photo, width: 150, height: 190)
                    }
                }
            }
        }
    }

    private var allScreenshotSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("전체 캡쳐")
                .font(.headline)

            if viewModel.allScreenshots.isEmpty {
                emptyView
            } else {
                LazyVGrid(
                    columns: [
                        GridItem(.flexible()),
                        GridItem(.flexible()),
                        GridItem(.flexible())
                    ],
                    spacing: 12
                ) {
                    ForEach(viewModel.allScreenshots) { photo in
                        screenshotCard(photo: photo, width: nil, height: 120)
                    }
                }
            }
        }
    }

    private func screenshotCard(
        photo: ScreenshotPhoto,
        width: CGFloat?,
        height: CGFloat
    ) -> some View {
        Image(uiImage: photo.image)
            .resizable()
            .scaledToFill()
            .frame(width: width, height: height)
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .overlay(alignment: .bottomTrailing) {
                Button {
                    print("선택된 캡쳐:", photo.id)
                } label: {
                    Image(systemName: "plus.circle.fill")
                        .font(.title2)
                        .foregroundStyle(.white, .blue)
                        .padding(6)
                }
            }
            .clipped()
    }

    private var emptyView: some View {
        VStack(spacing: 12) {
            Image(systemName: "photo.on.rectangle")
                .font(.system(size: 40))
                .foregroundStyle(.gray)

            Text("가져올 수 있는 캡쳐 사진이 없어요")
                .font(.headline)

            Text("사진 접근을 허용하면 스크린샷 이미지를 불러올 수 있어요.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity, minHeight: 220)
    }
}

#Preview {
    AddView()
}
