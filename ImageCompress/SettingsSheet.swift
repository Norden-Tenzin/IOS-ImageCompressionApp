//
//  SettingsSheet.swift
//  ImageCompress
//
//  Created by Tenzin Norden on 7/8/23.
//

import SwiftUI
import RevenueCat

struct SettingsSheet: View {
    @Binding var selectedOption: Double
    @Binding var showSheet: Bool
    @Binding var exportSize: Double
    @Binding var deleteOriginal: Bool

    var body: some View {
        VStack (alignment: .center) {
//            RoundedRectangle(cornerRadius: 5)
//                .foregroundStyle(Color.systemGray4)
//                .frame(width: 75, height: 4, alignment: .center)
//                .padding(.vertical, 10)
//            HStack {
////                Button {
////                    showSheet.toggle()
////                } label: {
////                    Text("Cancel")
////                }.padding(.leading, 10)
////                Spacer()
//                Text("Settings")
//                    .font(.system(size: 17, weight: .medium))
////                Spacer()
////                Button {
////                    exportSize = selectedOption
////                    showSheet.toggle()
////                } label: {
////                    Text("Save")
////                }.padding(.trailing, 10)
//                Button(action: {
//                    showSheet.toggle()
//                }, label: {
//                        Text("Done")
//                    })
//            }
            HStack {
                Spacer()
                Text("Settings")
                    .font(.system(size: TEXTSIZE, weight: .bold))
                Spacer()
            }
                .padding(.horizontal)
                .padding(.vertical)
                .overlay(alignment: .trailing, content: {
                Button(action: {
                    showSheet.toggle()
                }, label: {
                        Text("Done")
                    })
            })
                .padding(.horizontal, 20)
            VStack {
                HStack {
                    Text("Set approx size")
                        .frame(maxWidth: 150, alignment: .leading)
                    Spacer()
                    Picker(selection: $selectedOption, label: Text("Select Format")) {
                        ForEach([0.5, 0.6, 0.7, 0.8, 0.9, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10], id: \.self) { number in
                            if number < 1 {
                                Text("< \(Int(number * 1000)) kb")
                                    .font(.system(size: TEXTSIZE))
                            } else {
                                Text("< \(Int(number)) mb")
                                    .font(.system(size: TEXTSIZE))
                            }
                        }
                    }
                        .onAppear {
                        selectedOption = exportSize
                    }
                        .frame(maxWidth: 120, maxHeight: 150)
                        .pickerStyle(WheelPickerStyle())
                }
                    .font(.system(size: TEXTSIZE))
                    .padding([.leading])
                Divider()
                HStack {
                    Text("Export format")
                    Spacer()
                    Text("JPEG")
                        .padding(.vertical, 2)
                        .padding(.horizontal, 4)
                        .background(Color.systemGray3)
                        .foregroundStyle(.primary)
                        .clipShape(RoundedRectangle(cornerRadius: 5.0))
                }
                    .font(.system(size: TEXTSIZE))
                    .padding()
                    .padding(.bottom, 10)
            }
                .background(Color.systemGray5)
                .cornerRadius(8)
                .padding([.leading, .trailing])
            HStack {
                Toggle(isOn: $deleteOriginal, label: {
                    Text("Delete original")
                })
            }
                .font(.system(size: TEXTSIZE))
                .padding()
                .background(Color.systemGray5)
                .cornerRadius(8)
                .padding(.horizontal)
            HStack {
                Text("Please note that you will still be prompted for confirmation.")
                    .font(.system(size: 14))
                    .foregroundStyle(Color.secondary)
                    .frame(alignment: .leading)
                Spacer()
            }
                .padding(.leading, 20)
                .padding(.top, 4)
                .lineSpacing(3)
            Spacer()
            Text("Like what i do?")
                .padding(.top, 30)
            Text("Say hi 👋") + Text("[@norden](https://twitter.com/nordten)")
            Spacer()
            Button(action: {
                exportSize = selectedOption
                showSheet.toggle()
            }, label: {
                    RoundedRectangle(cornerRadius: 10)
                        .overlay {
                        Text("Save")
                            .font(.system(size: TEXTSIZE, weight: .medium))
                            .padding(.vertical, 10)
                            .foregroundColor(Color.white)
                            .cornerRadius(10)
                    }
                        .foregroundStyle(Color("secondary-color"))
                        .frame(height: BUTTONHEIGHT)
                })
                .padding()
        }
            .font(.system(size: TEXTSIZE))
            .presentationDetents([.height(600)])
            .background(Color.systemGray6)
    }
}
