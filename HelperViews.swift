//
//  HelperViews.swift
//  ImageCompress
//
//  Created by Tenzin Norden on 10/27/23.
//

import SwiftUI

struct Shine: View {
    var color: Color
    var body: some View {
        TimelineView(.animation) { context in
            let period = 1.0
            let t = 2 / period * context.date.timeIntervalSinceReferenceDate.remainder(dividingBy: period)
            LinearGradient(
                gradient: .init(stops: [
                    // Important: Don't use .clear. After masking
                    // (later in this answer), the colors come out
                    // better with .yellow.opacity(0).
                    .init(color: color.opacity(0), location: t + 0.3),
                        .init(color: color, location: t + 0.4),
                        .init(color: color, location: t + 0.6),
                        .init(color: color.opacity(0), location: t + 0.7),
                    ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        }
    }
}

struct Progress: View {
    var text: String
    var size: Double
    var color: Color
    var body: some View {
        TimelineView(.animation) { context in
            let period = 2.0
            let t = 2 / period * context.date.timeIntervalSinceReferenceDate.remainder(dividingBy: period)
            HStack(spacing: 0) {
                Text(text)
                Text(".")
                    .foregroundStyle(t > -0.5 ? color : Color.clear)
                Text(".")
                    .foregroundStyle(t > 0 ? color : Color.clear)
                Text(".")
                    .foregroundStyle(t > 0.5 ? color : Color.clear)
            }
                .font(Font.custom("PressStart2P-Regular", size: size))
                .foregroundColor(color)
        }
    }
}
