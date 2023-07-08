//
//  SettingsSheet.swift
//  ImageCompress
//
//  Created by Tenzin Norden on 7/8/23.
//

import SwiftUI

struct SettingsSheet: View {
    @Binding var selectedOption: Double
    @Binding var showSheet: Bool
    @Binding var exportSize: Double
    var body: some View {
        VStack (alignment: .leading) {
            HStack {
                Button {
                    showSheet.toggle()
                } label: {
                    Text("Cancel")
                }.padding(.leading, 10)
                Spacer()
                Text("Export Settings")
                    .font(.system(size: 18, weight: .bold))
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
                Text("Set approx export size")
                    .font(.system(size: 18))
                    .frame(maxWidth: 150, alignment: .leading)
                Spacer()
                Picker(selection: $selectedOption, label: Text("Select Format")) {
                    ForEach([0.5, 0.6, 0.7, 0.8, 0.9, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10], id: \.self) { number in
                        let decimalFormat = String(format: "%.1f", number)
                        if number.truncatingRemainder(dividingBy: 1) == 0 {
                            Text("< \(Int(number)) mb")
                        } else {
                            Text("< \(decimalFormat) mb")
                        }
                    }.font(.system(size: 18))
                }
                    .onAppear {
                    selectedOption = exportSize
                }
                    .frame(maxWidth: 120, maxHeight: 150)
                    .pickerStyle(WheelPickerStyle())
            }
                .padding([.leading])
                .background(Color("section-color"))
                .cornerRadius(8)
                .padding([.leading, .trailing])
            //                                .padding([.leading, .trailing])
            HStack {
                Text("File format")
                Spacer()
                Text(".jpg")
                    .padding(.trailing, 25)
            }
                .padding()
                .background(Color("section-color"))
                .cornerRadius(8)
                .padding([.leading, .trailing])
            Spacer()
        }
            .font(.system(size: 16))
            .presentationDetents([.height(600)])
            .background(Color("sheet-color"))
    }
}
//
//struct SettingsSheet_Previews: PreviewProvider {
//    @State static var selectedOption = 1.0
//    @State static var showSheet = true
//    @State static var exportSize = 1.0
//    static var previews: some View {
//        SettingsSheet(selectedOption: $selectedOption, showSheet: $showSheet, exportSize: $exportSize)
//    }
//}
