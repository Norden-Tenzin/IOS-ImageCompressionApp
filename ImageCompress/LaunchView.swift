//
//  LaunchView.swift
//  ImageCompress
//
//  Created by Tenzin Norden on 4/15/23.
//

import PhotosUI
import SwiftUI
import Combine

struct LaunchView: View {
//  Environment Var
    @Environment(\.colorScheme) var colorScheme
//  Saved Data
    @AppStorage("EXPORT_SIZE") var exportSize: Double = 1.0
    @AppStorage("FIRST_TIME") var firstTime: Bool = true
    @AppStorage("EXPORT_TYPE") var exportType: String = ""
//  Image Picker
    @ObservedObject var imagePicker = ImagePicker()

//  Status
    @State private var showSheet = false
    @State private var isActive = true
    @State private var isFinished = false
    @State private var isCompressRunning = false
    @State private var isShowingDetailView = false
    @State private var saveAlert = false
    @State private var resetAlert = false
    @State private var allDisabledAlert = false
//  Picker
    @State private var selectedOption: Double = 1.0

    func compressImages(targetSize: Double) {
//        print("TargetSIZE: \(targetSize)")
        isCompressRunning = true
        for (index, _) in imagePicker.images.enumerated() {
            let temp = imagePicker.images[index].copy()
            imagePicker.images[index] = ImageData(image: temp.image, imageSize: temp.imageSize, imageType: temp.imageType, isLoading: true, isDisabled: temp.isDisabled)
        }
//        imagePicker.images.forEach { imageData in
//            imageData.printInfo()
//        }
        DispatchQueue.global(qos: .userInitiated).async {
            for (index, image) in imagePicker.images.enumerated() {
//                print("isLoading Before: \(imagePicker.images[index].isLoading)")
                if (image.imageSize <= targetSize) {
                    DispatchQueue.main.async {
                        let temp = imagePicker.images[index].copy()
                        imagePicker.images[index] = ImageData(image: temp.image, imageSize: temp.imageSize, imageType: temp.imageType, isLoading: false, isDisabled: temp.isDisabled)
                    }
                } else {
                    let compressedImage: ImageData = compressImage_2(image: image, targetSize: targetSize)
                    DispatchQueue.main.async {
                        imagePicker.images[index] = compressedImage
                    }
                }
//                print("isLoading After: \(imagePicker.images[index].isLoading)")
            }
            isFinished = true
            isCompressRunning = false
        }
    }
    func disable(index: Int) {
        imagePicker.images[index].isDisabled.toggle()
        imagePicker.images[index] = imagePicker.images[index]
    }
    func reset() {
        imagePicker.reset()
        isFinished = false
    }

    var body: some View {
        NavigationView {
            VStack {
                if (imagePicker.images.isEmpty) {
                    UploadPage(imagePicker: imagePicker)
                        .frame(
                        maxWidth: .infinity,
                        maxHeight: .infinity
                    )
                }
                else {
                    ImageCompressionPage(selectedOption: $selectedOption, imagePicker: imagePicker, isFinished: $isFinished, isCompressRunning: $isCompressRunning, resetAlert: $resetAlert, isActive: $isActive, allDisabledAlert: $allDisabledAlert, saveAlert: $saveAlert, firstTime: $firstTime, showSheet: $showSheet, disable: disable, reset: reset, compressImages: compressImages)
                }
            }
                .alert(isPresented: $resetAlert) {
                Alert(title: Text("Are you sure you want to reset the images?"),
                    primaryButton:
                        .destructive(Text("Confirm")) {
                        reset()
                    },
                    secondaryButton:
                        .cancel()
                )
            }
                .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    if (colorScheme == .light) {
                        Image("picpac-black")
                    } else {
                        Image("picpac-white")
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showSheet.toggle()
                    } label: {
                        if (colorScheme == .light) {
                            Image(systemName: "gearshape.fill")
                                .tint(.black)
                        } else {
                            Image(systemName: "gearshape.fill")
                                .tint(.white)
                        }
                    }
                        .sheet(isPresented: $showSheet) {
                        SettingsSheet(selectedOption: $selectedOption, showSheet: $showSheet, exportSize: $exportSize)
                    }
                }
            }
                .conditionalModifier(colorScheme == .light, LightBorder(width: 2, edges: [.top]), DarkBorder(width: 2, edges: [.top]))
                .ignoresSafeArea(.container, edges: .bottom)
                .background(Color("background"))
        }
    }
}

#Preview {
    LaunchView()
}


