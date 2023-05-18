//
//  LaunchView.swift
//  ImageCompress
//
//  Created by Tenzin Norden on 4/15/23.
//

import PhotosUI
import SwiftUI
import Giffy
import Combine

struct LaunchView: View {
//  Environment Var
    @Environment(\.colorScheme) var colorScheme
//  Saved Data
    @AppStorage("EXPORT_SIZE") var exportSize: Int = 1
    @AppStorage("FIRST_TIME") var firstTime: Bool = true
    @AppStorage("EXPORT_TYPE") var exportType: String = ""
//  Image Picker
    @StateObject var imagePicker = ImagePicker()
//  Status
    @State private var showSheet = false
    @State private var isActive = true
    @State private var isFinished = false
    @State private var isCompressRunning = false
    @State private var isShowingDetailView = false
    @State private var saveAlert = false
    @State private var resetAlert = false
//  Picker
    @State private var selectedOption: Int = 1

// MARK: - Deprecated
    func compressImage(image: UIImage, targetSize: Int) -> Data? {
        guard let cgImage = image.cgImage else { return nil }
        let data = CFDataCreateMutable(kCFAllocatorDefault, 0)!
        let destination = CGImageDestinationCreateWithData(data, UTType.jpeg.identifier as CFString, 1, nil)!
        let options = [kCGImageDestinationLossyCompressionQuality: 0.5] as CFDictionary
        CGImageDestinationAddImage(destination, cgImage, options)
        CGImageDestinationFinalize(destination)
        let imageData = data as Data
        print("imgSize \(imageData.count)")
        print("targetSize \(targetSize * 1024 * 1024)")
        return imageData.count > (targetSize * 1024 * 1024) ? nil : imageData
    }
    
    func compressImage_my(image: ImageData, targetSize: Int) {
        var currSize: Double = image.imageSize
        var currImage: UIImage = image.image
        while(currSize > Double(targetSize)) {
            print("running")
            let data = compressJpeg(image: currImage, quality: 0.0)!
            currSize = getSizeMb(data: data)
            currImage = UIImage(data: data)!
        }
        print("ran at \(currSize) : \(Double(targetSize))")
        image.image = currImage
        image.imageSize = currSize
    }

// MARK: - InUse Funcs
    func compressImage_1(image: ImageData, targetSize: Int) -> ImageData {
        guard let cgImage = image.image.cgImage else { return image }
        let targetSizeInBytes = targetSize * 1024 * 1024
        var compressionQuality: CGFloat = 1.0
        var imageData: Data?
        while compressionQuality > 0 {
            print("running at: \(compressionQuality)")
            let data = CFDataCreateMutable(kCFAllocatorDefault, 0)!
            let destination = CGImageDestinationCreateWithData(data, UTType.jpeg.identifier as CFString, 1, nil)!
            let options = [kCGImageDestinationLossyCompressionQuality: compressionQuality] as CFDictionary
            CGImageDestinationAddImage(destination, cgImage, options)
            CGImageDestinationFinalize(destination)
            imageData = data as Data
            if imageData!.count <= targetSizeInBytes {
                break
            }
            compressionQuality -= 0.1
        }
        print("ran at \(getSizeMb(data: imageData!)) : \(Double(targetSize))")
        return ImageData(image: UIImage(data: imageData!)!, imageSize: getSizeMb(data: imageData!), imageType: image.imageType, isLoading: false, isDisabled: image.isDisabled)
    }
    
    func compressImages(targetSize: Int) {
        isCompressRunning = true
        for (index, _) in imagePicker.images.enumerated() {
            let temp = imagePicker.images[index].copy()
            imagePicker.images[index] = ImageData(image: temp.image, imageSize: temp.imageSize, imageType: temp.imageType, isLoading: true, isDisabled: temp.isDisabled)
        }
        imagePicker.images.forEach { imageData in
            imageData.printInfo()
        }
        DispatchQueue.global(qos: .userInitiated).async {
            for (index, image) in imagePicker.images.enumerated() {
                print("isLoading Before: \(imagePicker.images[index].isLoading)")
                if (image.imageSize <= Double(targetSize)) {
                    DispatchQueue.main.async {
                        let temp = imagePicker.images[index].copy()
                        imagePicker.images[index] = ImageData(image: temp.image, imageSize: temp.imageSize, imageType: temp.imageType, isLoading: false, isDisabled: temp.isDisabled)
                    }
                } else {
                    let compressedImage: ImageData = compressImage_1(image: image, targetSize: targetSize)
                    DispatchQueue.main.async {
                        imagePicker.images[index] = compressedImage
                    }
                }
                print("isLoading After: \(imagePicker.images[index].isLoading)")
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
                    VStack {
                        HStack {
                            Text("Images")
                                .font(.title2)
                                .fontWeight(.bold)
                            Spacer()
                            if (!isFinished) {
                                PhotosPicker(
                                    selection: $imagePicker.imageSelections,
                                    maxSelectionCount: 5,
                                    matching: .images
                                ) {
                                    Text("Edit Selection")
                                }.disabled(isCompressRunning)
                            } else {
                                Button(role: .destructive) {
                                    resetAlert = true
                                } label: {
                                    Text("Reset Selection")
                                }
                            }
                        }.padding([.top, .leading, .trailing])
                        if (isFinished) {
                            List {
                                ForEach(0..<imagePicker.images.count, id: \.self) { index in
                                    if (imagePicker.images[index].isDisabled) {
                                        ImageCell(imageData: imagePicker.images[index])
                                            .opacity(0.5)
                                            .swipeActions(edge: .leading, allowsFullSwipe: true, content: {
                                            Button {
                                                disable(index: index)
                                                print("new opacity: \(imagePicker.images[index].isDisabled)")
                                            } label: {
                                                Text("Disable")
                                            }
                                        })
                                    } else {
                                        ImageCell(imageData: imagePicker.images[index])
                                            .swipeActions(edge: .leading, allowsFullSwipe: true, content: {
                                            Button {
                                                disable(index: index)
                                                print("new noOpacity: \(imagePicker.images[index].isDisabled)")
                                            } label: {
                                                Text("Disable")
                                            }
                                        })
                                    }
                                }
                            }
                                .listStyle(.plain)
                                .navigationViewStyle(StackNavigationViewStyle())
                        } else {
                            List {
                                ForEach(imagePicker.images) { image in
                                    ImageCell(imageData: image)
                                }
                            }
                                .listStyle(.plain)
                                .navigationViewStyle(StackNavigationViewStyle())
                        }

                        if (!isFinished) {
                            Button {
                                isActive = false
                                compressImages(targetSize: selectedOption)
                                isActive = true
                            } label: {
                                Text("Compress")
                                    .frame(minWidth: 100, maxWidth: .infinity, minHeight: 44)
                                    .font(.title2)
                                    .padding(.vertical, 10)
                                    .background(Color("secondary-color"))
                                    .foregroundColor(Color.white)
                                    .cornerRadius(20)
                                    .padding(.horizontal, 20)
                            }
                                .padding(.bottom, 40)
                                .disabled(!isActive)
                        } else {
                            Button {
                                for image in imagePicker.images {
                                    let imageSaver = ImageSaver()
                                    if !image.isDisabled {
                                        imageSaver.writeToPhotoAlbum(image: image.image)
                                    }
                                }
                                saveAlert = true
                                reset()
                            } label: {
                                Text("Save All (\(imagePicker.images.filter { image in image.isDisabled == false }.count))")
                                    .frame(minWidth: 100, maxWidth: .infinity, minHeight: 44)
                                    .font(.title2)
                                    .padding(.vertical, 10)
                                    .background(Color("secondary-color"))
                                    .foregroundColor(Color.white)
                                    .cornerRadius(20)
                                    .padding(.horizontal, 20)
                            }
                                .padding(.bottom, 40)
                        }
                    }
                        .onAppear {
                        if (firstTime) {
                            showSheet = true
                            firstTime = false
                        }
                    }
                }
            }
                .alert("(\(imagePicker.images.filter { image in image.isDisabled == false }.count)) Images Saved ", isPresented: $saveAlert) {
                Button("OK", role: .cancel) { }
            }
                .alert("Are you sure you want to reset the images?", isPresented: $resetAlert) {
                Button("Confirm", role: .cancel) {
                    reset()
                }
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
                            Image(systemName: "gearshape")
                                .tint(.black)
                        } else {
                            Image(systemName: "gearshape")
                                .tint(.white)
                        }
                    }
                        .sheet(isPresented: $showSheet) {
                        VStack (alignment: .leading) {
                            HStack {
                                Button {
                                    showSheet.toggle()
                                } label: {
                                    Text("Cancel")
                                }.padding(.leading, 10)
                                Spacer()
                                Text("Export Settings")
                                    .fontWeight(.bold)
                                Spacer()
                                Button {
                                    exportSize = selectedOption
                                    showSheet.toggle()
                                } label: {
                                    Text("Save")
                                }.padding(.trailing, 10)
                            }
                                .padding([.leading, .trailing, .top])
                            HStack {
                                Text("Set export size for each file")
                                    .frame(maxWidth: 150, alignment: .leading)
                                Spacer()
                                Picker(selection: $selectedOption, label: Text("Select Format")) {
                                    ForEach(1...20, id: \.self) { number in
                                        Text("\(number)mb")
                                            .font(.system(size: 16))
                                    }
                                }
                                    .onAppear {
                                    selectedOption = exportSize
                                }
                                    .frame(maxWidth: 120)
                                    .pickerStyle(WheelPickerStyle())
                            }
                                .padding([.leading, .trailing])
                                .background(Color("section-color"))
                                .cornerRadius(8)
                                .padding([.leading, .trailing])
                            HStack {
                                Text("File format")
                                Spacer()
                                Text(".jpg")
                                    .padding(.trailing, 50)
                            }
                                .padding()
                                .background(Color("section-color"))
                                .cornerRadius(8)
                                .padding()
                            Spacer()
                        }
                            .font(.system(size: 16))
                            .presentationDetents([.height(600)])
                    }
                }

            }
                .conditionalModifier(colorScheme == .light, LightBorder(width: 2, edges: [.top]), DarkBorder(width: 2, edges: [.top]))
                .ignoresSafeArea(.container, edges: .bottom)
                .background(Color("background"))
        }
    }
}

struct LaunchView_Previews: PreviewProvider {
    static var previews: some View {
        LaunchView()
    }
}


