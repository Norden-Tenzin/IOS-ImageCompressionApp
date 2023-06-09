//
//  ImageCompressionPage.swift
//  ImageCompress
//
//  Created by Tenzin Norden on 7/8/23.
//

import PhotosUI
import SwiftUI

struct ImageCompressionPage: View {
    @Binding var selectedOption: Double
    @ObservedObject var imagePicker: ImagePicker
    @Binding var isFinished: Bool
    @Binding var isCompressRunning: Bool
    @Binding var resetAlert: Bool
    @Binding var isActive: Bool
    @Binding var allDisabledAlert: Bool
    @Binding var saveAlert: Bool
    @Binding var firstTime: Bool
    @Binding var showSheet: Bool

    var disable: (_ index: Int) -> Void
    var reset: () -> Void
    var compressImages: (_ targetSize: Double) -> Void

    var body: some View {
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
                                .listRowSeparator(.hidden)
                                .opacity(0.5)
                                .swipeActions(edge: .leading, allowsFullSwipe: true, content: {
                                Button {
                                    disable(index)
                                    //                                                print("new opacity: \(imagePicker.images[index].isDisabled)")
                                } label: {
                                    Text("Select")
                                }.tint(.green)
                            })
                        } else {
                            ImageCell(imageData: imagePicker.images[index])
                                .listRowSeparator(.hidden)
                                .swipeActions(edge: .leading, allowsFullSwipe: true, content: {
                                Button {
                                    disable(index)
                                    //                                                print("new noOpacity: \(imagePicker.images[index].isDisabled)")
                                } label: {
                                    Text("Deselect")
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
                            .listRowSeparator(.hidden)
                    }
                }
                    .listStyle(.plain)
                    .navigationViewStyle(StackNavigationViewStyle())
            }

            if (!isFinished) {
                Button {
                    isActive = false
                    compressImages(selectedOption)
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
                    if (imagePicker.images.filter { image in image.isDisabled == false }.count == 0) {
                        allDisabledAlert = true
                        //                                    print (allDisabledAlert)
                    } else {
                        for image in imagePicker.images {
                            let imageSaver = ImageSaver()
                            if !image.isDisabled {
                                imageSaver.writeToPhotoAlbum(image: image.image)
                            }
                        }
                        saveAlert = true
                    }
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
                    .alert("No Images Selected", isPresented: $allDisabledAlert) {
                    Button("OK", role: .cancel) {
                        allDisabledAlert = false
                    } }
                    .alert("Images Saved", isPresented: $saveAlert) {
                    Button("OK", role: .cancel) {
                        saveAlert = false
                        reset()
                    } }
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

//
//struct ImageCompressionPage_Previews: PreviewProvider {
//    static var previews: some View {
//        ImageCompressionPage()
//    }
//}
