//
//  MyView.swift
//  CaptureMate
//
//  Created by 허채윤 on 4/6/26.
//

import SwiftUI

struct MyView: View {
    var body: some View {
        ZStack {
            Color(.systemGroupedBackground).ignoresSafeArea()

            Text("My Page View")
                .font(.title2)
                .fontWeight(.semibold)
        }
    }
}
