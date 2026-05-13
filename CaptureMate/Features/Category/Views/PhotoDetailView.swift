//
//  PhotoDetailView.swift
//  CaptureMate
//
//  Created by 허채윤 on 5/13/26.
//

import SwiftUI

struct PhotoDetailView: View {
    let photo: CategoryPhotoItem

    @Environment(\.dismiss) private var dismiss
    @State private var showCaption = false

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

                    Text("분류 결과, OCR 텍스트, 추천 액션 등이 여기에 표시돼요.")
                        .font(.system(size: 14))
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                }
                .padding(.horizontal, 20)
                .padding(.top, 12)
                .padding(.bottom, 34)
                .frame(maxWidth: .infinity)
                .background(Color.white)
                .clipShape(RoundedRectangle(cornerRadius: 24))
                .offset(y: showCaption ? 0 : 170)
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
                .animation(.spring(), value: showCaption)
            }
        }
    }
}
