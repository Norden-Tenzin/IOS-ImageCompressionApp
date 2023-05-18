//
//  Extension.swift
//  ImageCompress
//
//  Created by Tenzin Norden on 5/18/23.
//

import SwiftUI
import PhotosUI

// MARK: - Extenssions

class ImageSaver: NSObject {
    func writeToPhotoAlbum(image: UIImage) {
        UIImageWriteToSavedPhotosAlbum(image, self, #selector(saveCompleted), nil)
    }
    @objc func saveCompleted(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
        print("Save finished!")
    }
}



struct EdgeBorder: Shape {
    var width: CGFloat
    var edges: [Edge]
    func path(in rect: CGRect) -> Path {
        var path = Path()
        for edge in edges {
            var x: CGFloat {
                switch edge {
                case .top, .bottom, .leading: return rect.minX
                case .trailing: return rect.maxX - width
                }
            }

            var y: CGFloat {
                switch edge {
                case .top, .leading, .trailing: return rect.minY
                case .bottom: return rect.maxY - width
                }
            }

            var w: CGFloat {
                switch edge {
                case .top, .bottom: return rect.width
                case .leading, .trailing: return self.width
                }
            }

            var h: CGFloat {
                switch edge {
                case .top, .bottom: return self.width
                case .leading, .trailing: return rect.height
                }
            }
            path.addPath(Path(CGRect(x: x, y: y, width: w, height: h)))
        }
        return path
    }
}

extension View {
    public func border(width: CGFloat, edges: [Edge], color: Color) -> some View {
        overlay(EdgeBorder(width: width, edges: edges).foregroundColor(color))
    }
    // Apply trueModifier if condition is met, or falseModifier if not.
    public func conditionalModifier<M1, M2>(_ condition: Bool, _ trueModifier: M1, _ falseModifier: M2) -> some View where M1: ViewModifier, M2: ViewModifier {
        Group {
            if condition {
                self.modifier(trueModifier)
            } else {
                self.modifier(falseModifier)
            }
        }
    }
}

struct LightBorder: ViewModifier {
    let width: CGFloat
    let edges: [Edge]

    func body(content: Content) -> some View {
        content.border(width: width, edges: edges, color: Color.black)
    }
}

struct DarkBorder: ViewModifier {
    let width: CGFloat
    let edges: [Edge]

    func body(content: Content) -> some View {
        content.border(width: width, edges: edges, color: Color.white)
    }
}
