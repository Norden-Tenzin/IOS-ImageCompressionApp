//
//  UploadPage.swift
//  ImageCompress
//
//  Created by Tenzin Norden on 5/18/23.
//

import Foundation
import PhotosUI
import SwiftUI

struct UploadPage: View {
//  Environment Variable
    @Environment(\.colorScheme) var colorScheme
    @ObservedObject var imagePicker: ImagePicker
    var body: some View {
        VStack (alignment: .center) {
            Spacer()
            if (colorScheme == .light) {
                Image("default_img_black")
            } else {
                Image("default_img_white")
            }
            Text("Welcome to PicPac")
                .font(.title)
                .fontWeight(.bold)
                .padding(.bottom)
            Group {
                Text("Get started by uploading")
                Text(" your images now.")
                    .padding(.bottom)
            }
                .frame(maxWidth: 200)
            PhotosPicker(
                selection: $imagePicker.imageSelections,
                maxSelectionCount: 5,
                matching: .images
            ) {
                Text("Upload")
                    .frame(minWidth: 100, maxWidth: 300, minHeight: 40)
                    .font(.title2)
                    .padding(.vertical, 10)
                    .background(Color("secondary-color"))
                    .foregroundColor(Color.white)
                    .cornerRadius(20)
                    .padding(.horizontal, 20)
            }.padding(.bottom, 40)
            Spacer(minLength: 250)
        }
    }
}

struct Upload_Previews: PreviewProvider {
    static var previews: some View {
        UploadPage(imagePicker: ImagePicker())
    }
}
