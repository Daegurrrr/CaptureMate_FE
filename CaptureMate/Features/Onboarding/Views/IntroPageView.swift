//
//  IntroPageView.swift
//  CaptureMate
//
//  Created by 허채윤 on 4/11/26.
//

import SwiftUI

struct IntroPageView: View {
    let page: IntroPage

    var body: some View {
        VStack(spacing: 0) {
            Spacer().frame(height: 10)

            Image(page.imageName)
                .resizable()
                .scaledToFit()
                .frame(width: 280, height: 500)

            Spacer().frame(height: 20)

            Text(page.title)
                .font(.system(size: 24, weight: .semibold))
                .foregroundColor(.black)
                .multilineTextAlignment(.center)
                .lineSpacing(6)
                .fixedSize(horizontal: false, vertical: true)
                .padding(.horizontal, 24)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
