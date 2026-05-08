//
//  RecentCaptureSection.swift
//  CaptureMate
//
//  Created by 허채윤 on 4/11/26.
//

import SwiftUI

struct RecentCaptureSection: View {
    let images: [UIImage]

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(Array(images.enumerated()), id: \.offset) { _, image in
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 110, height: 140)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                        .clipped()
                }
            }
        }
    }
}
