//
//  SummaryCard.swift
//  CaptureMate
//
//  Created by 허채윤 on 4/6/26.
//

import SwiftUI

struct SummaryCard: View {
    let title: String
    let count: String
    let bgColor: Color

    var body: some View {
        VStack(spacing: 8) {
            Text(title)
                .font(.system(size: 15))
                .foregroundColor(.gray)

            Text(count)
                .font(.system(size: 22, weight: .bold))
                .foregroundColor(.black)
        }
        .frame(maxWidth: .infinity)
        .frame(height: 86)
        .background(bgColor)
        .cornerRadius(14)
    }
}
