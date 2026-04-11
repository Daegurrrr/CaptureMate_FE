//
//  ToggleChip.swift
//  CaptureMate
//
//  Created by 허채윤 on 4/11/26.
//

import SwiftUI

struct ToggleChip: View {
    let title: String
    @Binding var isOn: Bool

    var body: some View {
        Button {
            isOn.toggle()
        } label: {
            HStack(spacing: 6) {
                Image(systemName: isOn ? "checkmark.square.fill" : "square")
                    .font(.system(size: 16))
                    .foregroundColor(isOn ? .blue : .secondary)

                Text(title)
                    .font(.system(size: 15))
                    .foregroundColor(.primary)
            }
        }
        .buttonStyle(.plain)
    }
}
