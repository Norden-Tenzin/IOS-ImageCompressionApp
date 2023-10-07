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
                Text("Get started by Adding")
                Text(" your images now.")
                    .padding(.bottom)
            }
                .frame(maxWidth: 200)
            Button {
                let authStatus = PHPhotoLibrary.authorizationStatus()
                switch authStatus
                {
                case .denied:
                    print("denied status")
                    photosAccessAlert = true
                    print(photosAccessAlert)
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
                Text("Add")
                    .frame(minWidth: 100, maxWidth: 300, minHeight: 40)
                    .font(.title2)
                    .padding(.vertical, 10)
                    .background(Color("secondary-color"))
                    .foregroundColor(Color.white)
                    .cornerRadius(20)
                    .padding(.horizontal, 20)
            }
                .padding(.bottom, 40)
            Spacer(minLength: 250)
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
            matching: .images)
    }
}
