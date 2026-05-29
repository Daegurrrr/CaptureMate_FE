//
//  PhotoDetailView.swift
//  CaptureMate
//
//  Created by 허채윤 on 5/13/26.
//

import SwiftUI
import SwiftData

struct PhotoDetailView: View {
    let photo: CategoryPhotoItem

    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext

    @State private var showCaption = false
    @State private var analysisRecord: PhotoAnalysisRecord?

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            VStack {
                Spacer()

                Image(uiImage: photo.image)
                    .resizable()
                    .scaledToFit()
                    .padding(.horizontal, 12)

                Spacer()
            }

            VStack {
                HStack {
                    Spacer()

                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 30))
                            .foregroundColor(.white)
                            .padding()
                    }
                }

                Spacer()
            }

            VStack {
                Spacer()

                VStack(spacing: 12) {
                    Capsule()
                        .fill(Color.gray.opacity(0.5))
                        .frame(width: 42, height: 5)

                    Text("캡쳐 정보")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.black)

                    VStack(alignment: .leading, spacing: 8) {
                        Text("분류 결과: \(analysisRecord?.category ?? "미분류")")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(.black)

                        if let actionData = analysisRecord?.actionData,
                           !actionData.isEmpty {
                            Text(actionData)
                                .font(.system(size: 13))
                                .foregroundColor(.gray)
                        } else {
                            Text("저장된 분석 결과가 없어요.")
                                .font(.system(size: 13))
                                .foregroundColor(.gray)
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
                .padding(.horizontal, 20)
                .padding(.top, 12)
                .padding(.bottom, 34)
                .frame(maxWidth: .infinity)
                .background(Color.white)
                .clipShape(RoundedRectangle(cornerRadius: 24))
                .offset(y: showCaption ? 0 : 220)
                .animation(.spring(), value: showCaption)
            }
        }
        .onAppear {
            loadAnalysis()
        }
        .contentShape(Rectangle())
        .gesture(
            DragGesture()
                .onEnded { value in
                    if value.translation.height < -40 {
                        showCaption = true
                    } else if value.translation.height > 40 {
                        showCaption = false
                    }
                }
        )
    }

    private func loadAnalysis() {
        let localId = photo.id

        let descriptor = FetchDescriptor<PhotoAnalysisRecord>(
            predicate: #Predicate { $0.localIdentifier == localId }
        )

        analysisRecord = try? modelContext.fetch(descriptor).first
    }
}
