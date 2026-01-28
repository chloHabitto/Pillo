//
//  ScreenHeader.swift
//  Pillo
//

import SwiftUI

struct ScreenHeader<Trailing: View>: View {
    let title: String
    @ViewBuilder let trailing: () -> Trailing

    init(title: String, @ViewBuilder trailing: @escaping () -> Trailing) {
        self.title = title
        self.trailing = trailing
    }

    var body: some View {
        HStack(alignment: .center, spacing: 0) {
            Text(title)
                .font(.appHeadlineLarge)
                .fontWeight(.bold)
                .foregroundStyle(Color("appText01"))
            Spacer(minLength: 0)
            trailing()
        }
        .padding(.horizontal, AppSpacing.screenHorizontal)
        .padding(.top, 16)
    }
}

extension ScreenHeader where Trailing == EmptyView {
    init(title: String) {
        self.title = title
        self.trailing = { EmptyView() }
    }
}
