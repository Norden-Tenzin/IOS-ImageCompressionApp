//
//  ImageCell.swift
//  ImageCompress
//
//  Created by Tenzin Norden on 5/18/23.
//

import Foundation
import PhotosUI
import SwiftUI
import Giffy

struct ImageCell: View {
    @ObservedObject var imageData: ImageData
    var body: some View {
        HStack (alignment: .top) {
            if (imageData.isLoading) {
                ZStack {
                    Image(uiImage: imageData.image)
                        .resizable()
                        .clipped()
                    Rectangle().foregroundColor(.black)
                        .opacity(0.8)
                    Circle()
                        .frame(width: 20, height: 20)
                        .foregroundColor(Color(.black))
                        .opacity(0.6)
                    Giffy("wedge2.0")
                }
                    .aspectRatio(16 / 9, contentMode: .fit)
                    .frame(height: 85)
            } else {
                Image(uiImage: imageData.image)
                    .resizable()
                    .aspectRatio(16 / 9, contentMode: .fit)
                    .clipped()
                    .frame(
                    height: 85,
                    alignment: .leading
                )
            }
            VStack(alignment: .leading) {
                Text("ImageName")
                Text(imageData.imageType)
                Text(String(format: "%.1fmb", imageData.imageSize))
            }
                .padding(.leading)
            Spacer()
        }
    }
}
