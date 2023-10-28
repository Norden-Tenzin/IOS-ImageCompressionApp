//
//  ImageCompressionPage.swift
//  ImageCompress
//
//  Created by Tenzin Norden on 7/8/23.
//

import PhotosUI
import SwiftUI
import UIKit
import UniformTypeIdentifiers
import MobileCoreServices

struct ImageCompressionPage: View {
    @Environment(\.colorScheme) var colorScheme
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
    @State var isPresentingShareSheet: Bool = false
    @Binding var deleteOriginal: Bool
    @State var displayCopyAlert: Bool = false

    var disable: (_ index: Int) -> Void
    var reset: () -> Void
    var compressImages: (_ targetSize: Double) -> Void

    var body: some View {
        VStack(spacing: 0) {
            Rectangle()
                .foregroundStyle(colorScheme == .light ? .black : .white)
                .frame(height: 2)
                .overlay(content: {
                if isCompressRunning {
                    Shine(color: Color.orange)
                } else {
                    Color.clear
                }
            })
            if isCompressRunning {
                Rectangle()
                    .frame(height: BUTTONHEIGHT)
                    .foregroundStyle(Color(light: Color.systemGray5, dark: Color.systemGray3))
                    .overlay {
                    Progress(text: "Compressing", size: 12, color: Color.primary)
                }
            }
//            HStack {
//                Text("Images")
//                    .font(.system(size: 18, weight: .heavy))
//                Spacer()
//                if (!isFinished) {
//                    PhotosPicker(
//                        selection: $imagePicker.imageSelections,
//                        maxSelectionCount: 5,
//                        matching: .images,
//                        photoLibrary: .shared()
//                    ) {
//                        Text("Edit")
//                            .font(.system(size: 17, weight: .medium))
//                    }.disabled(isCompressRunning)
//                } else {
//                    Button(role: .destructive) {
//                        resetAlert = true
//                    } label: {
//                        Text("Reset")
//                            .font(.system(size: 17, weight: .medium))
//                    }
//                }
//            }.padding([.top, .leading, .trailing, .bottom])
            if (isFinished) {
                List {
                    HStack {
                        Text("Selected Images (\(imagePicker.images.filter { imgdata in imgdata.isDisabled == false }.count))")
                            .font(.system(size: 18, weight: .heavy))
                        Spacer()
                        Button(role: .destructive) {
                            resetAlert = true
                        } label: {
                            Text("Reset")
                                .foregroundStyle(Color.red)
                                .font(.system(size: 17, weight: .medium))
                        }
                            .buttonStyle(PlainButtonStyle())
                    }
                        .listRowSeparator(.hidden)
                        .listRowSpacing(0)
                        .listRowInsets(EdgeInsets(.init(top: 32, leading: 15, bottom: 20, trailing: 15)))
                        .listRowBackground(Color("background"))
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
                                } label: {
                                    Text("Select")
                                }.tint(.green)
                            })
                                .swipeActions(edge: .trailing, allowsFullSwipe: true, content: {
                                Button {
                                    disable(index)
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
                                } label: {
                                    Text("Deselect")
                                }
                            })
                                .swipeActions(edge: .trailing, allowsFullSwipe: true, content: {
                                Button {
                                    disable(index)
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
                    HStack {
                        Text("Images")
                            .font(.system(size: 18, weight: .heavy))
                        Spacer()
                        PhotosPicker(
                            selection: $imagePicker.imageSelections,
                            maxSelectionCount: 5,
                            matching: .images,
                            photoLibrary: .shared()
                        ) {
                            Text("Edit")
                                .font(.system(size: 17, weight: .medium))
                                .foregroundStyle(Color.orange)
                        }
                            .buttonStyle(PlainButtonStyle())
                            .disabled(isCompressRunning)
                    }
                        .listRowSeparator(.hidden)
                        .listRowSpacing(0)
                        .listRowInsets(EdgeInsets(.init(top: 32, leading: 15, bottom: 20, trailing: 15)))
                        .listRowBackground(Color("background"))
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
                    RoundedRectangle(cornerRadius: 10)
                        .overlay {
                        VStack {
                            Text("Compress")
                        }
                            .font(.system(size: 20))
                            .foregroundStyle(Color.white)
                            .padding(.vertical, 10)
                    }
                        .frame(height: BUTTONHEIGHT)
                        .foregroundStyle(Color("secondary-color"))
                        .padding(.horizontal, 15)
                        .padding(.top, 15)
                }
                    .padding(.bottom, 30)
                    .disabled(!isActive)
            } else {
                HStack {
                    Button {
                        isPresentingShareSheet = true
                    } label: {
                        RoundedRectangle(cornerRadius: 10)
                            .overlay {
//                            Image(systemName: "square.and.arrow.up")
                            Text("Share")
                                .font(.system(size: TEXTSIZE))
                                .foregroundStyle(Color.white)
                                .padding(.vertical, 10)
                        }
                            .frame(height: BUTTONHEIGHT)
                            .foregroundStyle(Color("secondary-color"))
                    }
                        .foregroundStyle(Color("secondary-color"))
                        .frame(minWidth: 0, maxWidth: .infinity)
                        .padding(.bottom, 30)
                        .padding(.top, 15)
//                    Button {
//                        if imagePicker.images.filter({ img in
//                            img.isDisabled == false
//                        }).count > 0 {
//                            if deleteOriginal {
//                                Task {
//                                    await deleteImages(images: imagePicker.images)
//                                }
//                            }
//                            downloadImages(images: imagePicker.images, albumName: "PicPackr")
//                            saveAlert = true
//                        } else {
//                            allDisabledAlert = true
//                        }
//                    } label: {
//                        RoundedRectangle(cornerRadius: 10)
//                            .overlay {
//                            VStack {
//                                Text("Save (\(imagePicker.images.filter { image in image.isDisabled == false }.count))")
//                            }
//                                .font(.system(size: 20))
//                                .foregroundStyle(Color.white)
//                                .padding(.vertical, 10)
//                        }
//                            .frame(height: 60)
//                            .foregroundStyle(Color("secondary-color"))
//                    }
//                        .padding(.bottom, 30)
                }
                    .padding(.horizontal, 15)
            }
        }
            .animation(.bouncy, value: isCompressRunning)
            .sheet(isPresented: $isPresentingShareSheet, content: {
            VStack {
                HStack(alignment: .top) {
                    let filtered = imagePicker.images.filter { image in
                        image.isDisabled == false
                    }
                    ZStack {
                        RoundedRectangle(cornerRadius: 5)
                            .frame(width: 50, height: 50)
                            .foregroundStyle(Color.white)
                            .overlay {
                            Image(systemName: "photo.on.rectangle.angled")
                                .foregroundStyle(Color.black)
                        }
                            .shadow(radius: 5)
                        if 2 >= 0 && 2 < filtered.count {
                            Image(uiImage: filtered[2].image)
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: 50, height: 50)
                                .clipped()
                                .border(Color.white, width: 3)
                                .rotationEffect(Angle(degrees: Double.random(in: 0...360)))
                                .border(width: 5, edges: [], color: .white)
                        }
                        if 1 >= 0 && 1 < filtered.count {
                            Image(uiImage: filtered[1].image)
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: 50, height: 50)
                                .clipped()
                                .border(Color.white, width: 3)
                                .rotationEffect(Angle(degrees: Double.random(in: 0...360)))
                        }
                        if filtered.count > 0 {
                            if filtered.first!.isDisabled == false {
                                Image(uiImage: filtered.first!.image)
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(width: 48, height: 48)
                                    .clipped()
                                    .border(Color.white, width: 3)
                            }
                        }
                    }
                    Text("\(filtered.count) Photos Selected")
                        .font(.system(size: 16, weight: .semibold))
                        .padding(.leading, 10)
                    Spacer()
                    Button(action: { isPresentingShareSheet = false }, label: {
                            Circle()
                                .foregroundColor(Color(light: Color.systemGray4, dark: Color.systemGray5))
                                .frame(width: 30)
                                .overlay {
                                Image(systemName: "xmark")
                                    .foregroundColor(Color.systemGray)
                                    .font(.system(size: 18, weight: .bold))
                            }
                        })
                }
                    .padding([.top, .leading, .trailing], 15)
                    .padding(.bottom, 5)
                Divider()
                    .padding(.bottom, 15)
                VStack {
                    Button(action: {
                        let images: [UIImage] = imagePicker.images.filter { image in
                            image.isDisabled == false
                        }.map({ imgdata in
                            imgdata.image
                        })
                        // Copy the images to the clipboard
                        UIPasteboard.general.images = images
                        isPresentingShareSheet = false
                    }, label: {
                            RoundedRectangle(cornerRadius: 10)
                                .foregroundStyle(Color(light: Color.white, dark: Color.systemGray4))
                                .frame(height: BUTTONHEIGHT)
                                .overlay {
                                HStack {
                                    Text("Copy")
                                    Spacer()
                                    Image(systemName: "doc.on.doc")
                                        .font(.system(size: 22))
                                }
                                    .foregroundStyle(.primary)
                                    .padding(.horizontal, 15)
                            }
                                .padding(.horizontal, 15)
                        }
                    )
                        .buttonStyle(.plain)

//                    MARK: - SAVE BUTTON - TODO FIX ALERT NOT SHOWING UP
                    Button(action: {
                        saveAlert = true
                        if deleteOriginal {
                            Task {
                                await deleteImages(images: imagePicker.images)
                            }
                        }
                        downloadImages(images: imagePicker.images, albumName: "PicPackr")
                        isPresentingShareSheet = false
                        saveAlert = true
                    }, label: {
                            RoundedRectangle(cornerRadius: 10)
                                .foregroundStyle(Color(light: Color.white, dark: Color.systemGray4))
                                .frame(height: BUTTONHEIGHT)
                                .overlay {
                                HStack {
                                    Text("Save to Photos")
                                    Spacer()
                                    Image(systemName: "photo.badge.arrow.down")
                                        .font(.system(size: 22))
                                }
                                    .foregroundStyle(.primary)
                                    .padding(.horizontal, 15)
                            }
                                .padding(.horizontal, 15)
                        }
                    )
                        .buttonStyle(.plain)
                        .alert("No Images Selected", isPresented: $allDisabledAlert) {
                        Button("OK", role: .cancel) {
                            allDisabledAlert = false
                        }
                    }
                        .alert("Images Saved to albumn \"PicPackr\"", isPresented: $saveAlert) {
                        Button("OK", role: .cancel) {
                            saveAlert = false
                            reset()
                        }
                    }
                    Spacer()
                }
//                    .alert("No Images Selected", isPresented: $allDisabledAlert) {
//                    Button("OK", role: .cancel) {
//                        allDisabledAlert = false
//                    }
//                }
//                    .alert("Images Saved to albumn \"PicPackr\"", isPresented: $saveAlert) {
//                    Button("OK", role: .cancel) {
//                        saveAlert = false
//                        reset()
//                    }
//                }
            }
                .background(Color.systemGray6)
                .presentationDetents([.medium])
                .presentationBackground(Color.systemGray3)
        })
            .onAppear {
            if (firstTime) {
                showSheet = true
                firstTime = false
            }
        }
    }
}
