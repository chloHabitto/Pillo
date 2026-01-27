//
//  ProgressRingView.swift
//  Pillo
//

import SwiftUI

struct ProgressRingView: View {
    let progress: Double // 0-100
    var size: CGFloat = 48
    var strokeWidth: CGFloat = 4
    
    var body: some View {
        ZStack {
            Circle()
                .stroke(Color.secondary.opacity(0.2), lineWidth: strokeWidth)
            
            Circle()
                .trim(from: 0, to: min(progress / 100, 1.0))
                .stroke(Color.appPrimary, style: StrokeStyle(lineWidth: strokeWidth, lineCap: .round))
                .rotationEffect(.degrees(-90))
                .animation(.easeOut(duration: 0.5), value: progress)
            
            Text("\(Int(progress))%")
                .font(.system(size: 11, weight: .bold))
        }
        .frame(width: size, height: size)
    }
}
