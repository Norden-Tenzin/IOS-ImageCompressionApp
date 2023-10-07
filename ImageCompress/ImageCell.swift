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
            } else {
                Image(uiImage: imageData.image)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 120, height: 120)
                    .clipped()
            }
            VStack(alignment: .leading, spacing: 5) {
                HStack {
                    Text("format")
                    Spacer()
                    Text(".\(imageData.imageType)")
                }
                HStack {
                    Text("size")
                    Spacer()
                    if imageData.imageSize < 1 {
                        Text("\(Int(imageData.imageSize * 1024)) kb")
                    } else {
                        Text("\(String(format: "%.1f", imageData.imageSize)) mb")
                    }
                }
            }
                .font(.system(size: 18, weight: .light))
                .padding(.init(top: 2, leading: 10, bottom: 0, trailing: 0))
        }
            .listRowBackground(Color("background"))
    }
}
