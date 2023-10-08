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
//    private(set) var offerings: Offerings? = UserViewModel.shared.offerings

    var body: some View {
        VStack (alignment: .center) {
            RoundedRectangle(cornerRadius: 5)
                .foregroundStyle(Color.systemGray4)
                .frame(width: 75, height: 4, alignment: .center)
                .padding(.vertical, 10)
            HStack {
                Button {
                    showSheet.toggle()
                } label: {
                    Text("Cancel")
                }.padding(.leading, 10)
                Spacer()
                Text("Settings")
                    .font(.system(size: 17, weight: .medium))
                Spacer()
                Button {
                    exportSize = selectedOption
                    showSheet.toggle()
                } label: {
                    Text("Save")
                }.padding(.trailing, 10)
            }
                .padding(.horizontal)
            HStack {
                Text("Set approx export size")
                    .frame(maxWidth: 150, alignment: .leading)
                Spacer()
                Picker(selection: $selectedOption, label: Text("Select Format")) {
                    ForEach([0.5, 0.6, 0.7, 0.8, 0.9, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10], id: \.self) { number in
                        if number < 1 {
                            Text("< \(Int(number * 1000)) kb")
                        } else {
                            Text("< \(Int(number)) mb")
                        }
                    }.font(.system(size: 15))
                }
                    .onAppear {
                    selectedOption = exportSize
                }
                    .frame(maxWidth: 120, maxHeight: 150)
                    .pickerStyle(WheelPickerStyle())
            }
                .font(.system(size: 17))
                .padding([.leading])
                .background(Color.systemGray5)
                .cornerRadius(8)
                .padding([.leading, .trailing])
            HStack {
                Text("Export format")
                Spacer()
                Text(".JPG")
                    .padding(.vertical, 2)
                    .padding(.horizontal, 4)
                    .background(Color.systemGray3)
                    .foregroundStyle(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 5.0))
                    .padding(.trailing, 25)
            }
                .font(.system(size: 17))
                .padding()
                .background(Color.systemGray5)
                .cornerRadius(8)
                .padding([.leading, .trailing])
            Spacer()
            Text("Like what i do?")
                .padding(.top, 20)
            Text("Say hi 👋") + Text("[@norden](https://twitter.com/nordten)")

//            VStack {
//                ForEach(offerings?.current?.availablePackages ?? []) { pack in
//                    Text(pack.offeringIdentifier)
//                }
//            }

            Spacer()
        }
            .font(.system(size: 17))
            .presentationDetents([.height(600)])
            .background(Color.systemGray6)
    }
}

#Preview {
    @State var selectedOption = 1.0
    @State var showSheet = true
    @State var exportSize = 1.0
    return SettingsSheet(selectedOption: $selectedOption, showSheet: $showSheet, exportSize: $exportSize)
}
