//
//  Extension.swift
//  ImageCompress
//
//  Created by Tenzin Norden on 5/18/23.
//

import SwiftUI
import PhotosUI
import Photos

// MARK: - Extenssions

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

extension UIImage {
    func scalePreservingAspectRatio(width: Int, height: Int) -> UIImage {
        let widthRatio = CGFloat(width) / size.width
        let heightRatio = CGFloat(height) / size.height

        let scaleFactor = min(widthRatio, heightRatio)

        let scaledImageSize = CGSize(
            width: size.width * scaleFactor,
            height: size.height * scaleFactor
        )

        let format = UIGraphicsImageRendererFormat()
        format.scale = 1

        let renderer = UIGraphicsImageRenderer(
            size: scaledImageSize,
            format: format
        )

        let scaledImage = renderer.image { _ in
            self.draw(in: CGRect(
                origin: .zero,
                size: scaledImageSize
                ))
        }

        return scaledImage
    }

    func resized(withPercentage percentage: CGFloat, isOpaque: Bool = true) -> UIImage? {
        let canvas = CGSize(width: size.width * percentage, height: size.height * percentage)
        let format = imageRendererFormat
        format.opaque = isOpaque
        return UIGraphicsImageRenderer(size: canvas, format: format).image {
            _ in draw(in: CGRect(origin: .zero, size: canvas))
        }
    }

    func compress(to mb: Double, allowedMargin: CGFloat = 0.2) -> Data {
        let bytes = Int(mb * 1024 * 1024)
        var compression: CGFloat = 1.0
        let step: CGFloat = 0.05
        var holderImage = self
        var complete = false
        while(!complete) {
            if let data = holderImage.jpegData(compressionQuality: 1.0) {
                let ratio = data.count / bytes
//                print("ratio: \(ratio)")
                if data.count < bytes {
                    complete = true
                    return data
                } else {
                    let multiplier: CGFloat = CGFloat((ratio / 5) + 1)
                    compression -= (step * multiplier)
                }
            }
            guard let newImage = holderImage.resized(withPercentage: compression) else {
//                print("BROKE");
                break;
            }
            holderImage = newImage
        }
        return Data()
    }

    func resizeToApprox(sizeInMB: Double, deltaInMB: Double = 0.2) -> Data {
        let allowedSizeInBytes = Int(sizeInMB * 1024 * 1024)
        let deltaInBytes = Int(deltaInMB * 1024 * 1024)
        let fullResImage = self.jpegData(compressionQuality: 1.0)
        if (fullResImage?.count)! < Int(deltaInBytes + allowedSizeInBytes) {
            return fullResImage!
        }

        var i = 0

        var left: CGFloat = 0.0, right: CGFloat = 1.0
        var mid = (left + right) / 2.0
        var newResImage = self.jpegData(compressionQuality: mid)

        while (true) {
            i += 1
            if (i > 13) {
//                print("Compression ran too many times ") // ideally max should be 7 times as  log(base 2) 100 = 6.6
                break
            }
//            print("mid = \(mid)")
            if ((newResImage?.count)! < (allowedSizeInBytes - deltaInBytes)) {
                left = mid
            } else if ((newResImage?.count)! > (allowedSizeInBytes + deltaInBytes)) {
                right = mid
            } else {
//                print("loop ran \(i) times")
                return newResImage!
            }
            mid = (left + right) / 2.0
            newResImage = self.jpegData(compressionQuality: mid)
        }
        return self.jpegData(compressionQuality: 0.5)!
    }

    func resizeByByte(maxMb: Int) -> Data {
        var compressQuality: CGFloat = 1
        let maxByte = maxMb * 1024 * 1024
        var imageData = Data()
        var imageByte = self.jpegData(compressionQuality: 1)?.count
        while imageByte! > maxByte {
            imageData = self.jpegData(compressionQuality: compressQuality)!
            imageByte = self.jpegData(compressionQuality: compressQuality)?.count
            compressQuality -= 0.1
        }

        if maxByte > imageByte! {
            return imageData
        } else {
            return self.jpegData(compressionQuality: 1)!
        }
    }
}
