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
                Text("IMAGES")
                    .font(.system(size: 17, weight: .medium))
                Spacer()
                if (!isFinished) {
                    PhotosPicker(
                        selection: $imagePicker.imageSelections,
                        maxSelectionCount: 5,
                        matching: .images,
                        photoLibrary: .shared()
                    ) {
                        Text("Edit")
                            .font(.system(size: 17, weight: .medium))
                    }.disabled(isCompressRunning)
                } else {
                    Button(role: .destructive) {
                        resetAlert = true
                    } label: {
                        Text("Reset")
                            .font(.system(size: 17, weight: .medium))
                    }
                }
            }.padding([.top, .leading, .trailing])
            if (isFinished) {
                List {
                    ForEach(0..<imagePicker.images.count, id: \.self) { index in
                        if (imagePicker.images[index].isDisabled) {
                            ImageCell(imageData: imagePicker.images[index])
                                .listRowSeparator(.hidden)
                                .listRowSpacing(0)
                                .listRowInsets(EdgeInsets(.init(top: 5, leading: 15, bottom: 5, trailing: 15)))
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
                                .listRowSpacing(0)
                                .listRowInsets(EdgeInsets(.init(top: 5, leading: 15, bottom: 5, trailing: 15)))
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
                    ForEach(imagePicker.images, id: \.id) { image in
                        ImageCell(imageData: image)
                            .listRowSeparator(.hidden)
                            .listRowSpacing(0)
                            .listRowInsets(EdgeInsets(.init(top: 5, leading: 15, bottom: 5, trailing: 15)))
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
                        .cornerRadius(10)
                        .padding(.horizontal, 15)
                }
                    .padding(.bottom, 30)
                    .disabled(!isActive)
            } else {
                Button {
                    downloadImages(images: imagePicker.images, albumName: "PicPackr")
                    saveAlert = true
                } label: {
                    Text("Save (\(imagePicker.images.filter { image in image.isDisabled == false }.count))")
                        .frame(minWidth: 100, maxWidth: .infinity, minHeight: 44)
                        .font(.title2)
                        .padding(.vertical, 10)
                        .background(Color("secondary-color"))
                        .foregroundColor(Color.white)
                        .cornerRadius(10)
                        .padding(.horizontal, 15)
                }
                    .padding(.bottom, 30)
                    .alert("No Images Selected", isPresented: $allDisabledAlert) {
                    Button("OK", role: .cancel) {
                        allDisabledAlert = false
                    } }
                    .alert("Images Saved to albumn \"PicPackr\"", isPresented: $saveAlert) {
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
