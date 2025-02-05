//
//  ImageCell.swift
//  ImageCompress
//
//  Created by Tenzin Norden on 5/18/23.
//

import Foundation
import PhotosUI
import SwiftUI

struct ImageCell: View {
    @Environment(\.colorScheme) var colorScheme
    @ObservedObject var imageData: ImageData
    var body: some View {
        HStack (alignment: .top, spacing: 0) {
            if (imageData.isLoading) {
                ZStack {
                    Image(uiImage: imageData.image)
                        .resizable()
                    if (colorScheme == .light) {
                        Rectangle().foregroundColor(.white)
                            .opacity(0.25)
                    } else {
                        Rectangle().foregroundColor(.black)
                            .opacity(0.25)
                    }
                    ProgressView().scaleEffect(x: 1.25, y: 1.25, anchor: .center)
                }
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 120, height: 120)
                    .clipped()
                    .clipShape(.rect(
                    topLeadingRadius: 5,
                    bottomLeadingRadius: 5,
                    bottomTrailingRadius: 0,
                    topTrailingRadius: 0
                    ))
            } else {
                Image(uiImage: imageData.image)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 120, height: 120)
                    .clipped()
                    .clipShape(.rect(
                    topLeadingRadius: 5,
                    bottomLeadingRadius: 5,
                    bottomTrailingRadius: 0,
                    topTrailingRadius: 0
                    ))
            }
            VStack(alignment: .leading) {
                HStack {
                    Text("\(imageData.imageName)")
                    Spacer()
                }
                    .lineLimit(1)
                    .foregroundStyle(Color.primary)
                    .padding(.vertical, 5)
                    .padding(.horizontal, 10)
                    .background(Color.systemGray5)
                    .clipShape(.rect(
                    topLeadingRadius: 0,
                    bottomLeadingRadius: 0,
                    bottomTrailingRadius: 0,
                    topTrailingRadius: 5
                    ))
                HStack {
                    Text("Format")
                        .foregroundStyle(Color.primary)
                    Spacer()
                    Text("\(imageData.imageType.uppercased())")
                        .padding(.vertical, 2)
                        .padding(.horizontal, 4)
                        .background(Color.tertiaryLabel)
                        .foregroundStyle(.white)
                        .clipShape(.rect(
                        topLeadingRadius: 5,
                        bottomLeadingRadius: 5,
                        bottomTrailingRadius: 5,
                        topTrailingRadius: 5
                        ))
                }
                    .padding(.horizontal, 10)
                HStack {
                    Text("Size")
                        .foregroundStyle(Color.primary)
                    Spacer()
                    if imageData.imageSize < 1 {
                        Text("\(Int(imageData.imageSize * 1024)) KB")
                    } else {
                        Text("\(String(format: "%.1f", imageData.imageSize)) MB")
                    }
                }
                    .padding(.horizontal, 10)
                    .foregroundStyle(Color.secondary)
                Spacer()
            }
                .font(.system(size: 16, weight: .regular))
                .background(Color.systemGray6)
                .clipShape(.rect(
                topLeadingRadius: 0,
                bottomLeadingRadius: 0,
                bottomTrailingRadius: 5,
                topTrailingRadius: 5
                ))
                .frame(maxHeight: 120)

        }
            .listRowBackground(Color("background"))
            .padding(0)
    }
}

extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCorner(radius: radius, corners: corners))
    }
}
struct RoundedCorner: Shape {

    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(roundedRect: rect, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        return Path(path.cgPath)
    }
}

