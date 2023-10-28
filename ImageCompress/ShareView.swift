//
//  ShareView.swift
//  ImageCompress
//
//  Created by Tenzin Norden on 10/26/23.
//

import SwiftUI

struct ShareView: View {
    var body: some View {
        VStack {
            HStack(alignment: .top) {
                RoundedRectangle(cornerRadius: 10)
                    .frame(width: 50, height: 50)
                Spacer()
                Button(action: /*@START_MENU_TOKEN@*/ { }/*@END_MENU_TOKEN@*/, label: {
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
                .padding([.top, .leading, .trailing], 10)
                .padding(.bottom, 5)
            Divider()
                .padding(.bottom, 15)
            VStack {
                Button(action: /*@START_MENU_TOKEN@*/ { }/*@END_MENU_TOKEN@*/, label: {
                        RoundedRectangle(cornerRadius: 10)
                            .foregroundStyle(Color(light: Color.white, dark: Color.systemGray4))
                            .frame(height: 50)
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
                            .padding(.horizontal, 10)
                    }
                )
                    .buttonStyle(.plain)
                Button(action: /*@START_MENU_TOKEN@*/ { }/*@END_MENU_TOKEN@*/, label: {
                        RoundedRectangle(cornerRadius: 10)
                            .foregroundStyle(Color(light: Color.white, dark: Color.systemGray4))
                            .frame(height: 50)
                            .overlay {
                            HStack {
                                Text("Save Images")
                                Spacer()
                                Image(systemName: "square.and.arrow.down")
                                    .font(.system(size: 22))
                            }
                                .foregroundStyle(.primary)
                                .padding(.horizontal, 15)
                        }
                            .padding(.horizontal, 10)
                    }
                )
                    .buttonStyle(.plain)
                Spacer()
            }
        }
            .background(Color.systemGray6)
    }
}

#Preview {
    ShareView()
}
