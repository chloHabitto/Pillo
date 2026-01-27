//
//  ScreenHeader.swift
//  Pillo
//

import SwiftUI

struct ScreenHeader: View {
    let title: String

    var body: some View {
        Text(title)
            .font(.appHeadlineLarge)
            .fontWeight(.bold)
            .foregroundStyle(Color("appText01"))
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal)
            .padding(.top, 16)
    }
}
