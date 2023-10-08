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
//    Environment Variables
    @Environment(\.colorScheme) var colorScheme
    @ObservedObject var imageData: ImageData
    var body: some View {
        HStack (alignment: .top, spacing: 10) {
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
                    .clipShape(RoundedRectangle(cornerRadius: 5))
            } else {
                Image(uiImage: imageData.image)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 120, height: 120)
                    .clipped()
                    .clipShape(RoundedRectangle(cornerRadius: 5))
            }
            VStack(alignment: .leading) {
                HStack(alignment: .top) {
                    Text("name")
                    Spacer()
                    Text("\(imageData.imageName)")
                        .lineLimit(1)
                        .foregroundStyle(Color.secondary)
                }
                    .padding(.vertical, 5)
                    .padding(.horizontal, 10)
                    .background(Color.systemGray5)
                    .clipShape(.rect(
                    topLeadingRadius: 5,
                    bottomLeadingRadius: 0,
                    bottomTrailingRadius: 0,
                    topTrailingRadius: 5
                    ))
                HStack {
                    Text("format")
                        .foregroundStyle(Color.secondary)
                    Spacer()
                    Text("\(imageData.imageType)")
                        .padding(.vertical, 2)
                        .padding(.horizontal, 4)
                        .background(Color.tertiaryLabel)
                        .foregroundStyle(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 5.0))
                }
                    .padding(.horizontal, 10)
                HStack {
                    Text("size")
                        .foregroundStyle(Color.secondary)
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
                .clipShape(RoundedRectangle(cornerRadius: 5))
                .frame(maxHeight: 120)

        }
            .listRowBackground(Color("background"))
            .padding(0)
    }
}

#Preview {
    ImageCell(imageData: ImageData(image: UIImage(named: "AppIcon")!, imageName: "SOMEIMAGE", imageSize: 300, imageType: "HEIC"))
}
