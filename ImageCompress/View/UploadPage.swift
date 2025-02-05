//
//  UploadPage.swift
//  ImageCompress
//
//  Created by Tenzin Norden on 5/18/23.
//

import Foundation
import PhotosUI
import SwiftUI
//import RevenueCat

struct UploadPage: View {
    @Environment(\.colorScheme) var colorScheme
    @State var isPhotoPickerActive = false
    @State var photosAccessAlert = false
    @ObservedObject var imagePicker: ImagePicker

    var body: some View {
        VStack (alignment: .center) {
            Rectangle()
                .foregroundStyle(colorScheme == .light ? .black : .white)
                .frame(height: 2)
//                .overlay(content: { Shine(color: colorScheme == .light ?  Color.orange : Color.orange) })
            Spacer()
            if (colorScheme == .light) {
                Image("default_img_black")
            } else {
                Image("default_img_white")
            }
            Group {
                Text("Let's begin by adding your images")
                    .font(.system(size: 20))
                    .padding(.bottom)
                    .multilineTextAlignment(.center)
                    .lineSpacing(5)
            }
                .frame(maxWidth: 225)
                .padding(.bottom, 4)
                .padding(.top, 8)
            Spacer()
            Button {
                let authStatus = PHPhotoLibrary.authorizationStatus()
                switch authStatus
                {
                case .denied:
                    print("denied status")
                    photosAccessAlert = true
//                    print(photosAccessAlert)
                    //                            openAppSettings()
                    break
                case .authorized:
                    print("success")
                    isPhotoPickerActive = true
                    break
                case .restricted:
                    print("user dont allowed")
                    break
                case .notDetermined:
                    print("not Determined")
                    PHPhotoLibrary.requestAuthorization({ (newStatus) in
                        if (newStatus == PHAuthorizationStatus.authorized) {
                            print("permission granted")
                            isPhotoPickerActive = true
                        } else if (newStatus == PHAuthorizationStatus.limited) {
                            print("permission limited")
                            photosAccessAlert = true
                        } else {
                            print("permission not granted")
                        }
                    })
                    break
                case .limited:
                    print("limited")
                @unknown default:
                    break
                }
            } label: {
                RoundedRectangle(cornerRadius: 10)
                    .overlay {
                    Text("Add Images")
                        .font(.system(size: TEXTSIZE))
                        .foregroundColor(Color.primary)
                        .fontWeight(.medium)
                }
            }
                .frame(height: BUTTONHEIGHT)
                .foregroundStyle(Color("secondary-color"))
                .padding(.horizontal, 15)
                .padding(.bottom, 30)
        }
            .alert("Photos permissions is required to add images for compression select \"All Photos\".", isPresented: $photosAccessAlert, actions: {
            Button("Settings", role: .cancel) {
                photosAccessAlert = false
                openAppSettings()
            }
        })
            .photosPicker(
            isPresented: $isPhotoPickerActive,
            selection: $imagePicker.imageSelections,
            maxSelectionCount: 5,
            matching: .images,
            photoLibrary: .shared())
    }
}
