//
//  ImagePicker.swift
//  ImageCompress
//
//  Created by Tenzin Norden on 4/17/23.
//

import SwiftUI
import PhotosUI
import Foundation

class ImageData: ObservableObject, Identifiable {
    static func == (lhs: ImageData, rhs: ImageData) -> Bool {
        lhs.id == rhs.id
    }
    var id: UUID = UUID()
    var image: UIImage
    var imageSize: Double
    var imageType: String
    var isLoading: Bool
    var isDisabled: Bool

    init(image: UIImage, imageSize: Double, imageType: String) {
        self.image = image
        self.imageSize = imageSize
        self.imageType = imageType
        self.isLoading = false
        self.isDisabled = false
    }
    init(image: UIImage, imageSize: Double, imageType: String, isLoading: Bool, isDisabled: Bool) {
        self.image = image
        self.imageSize = imageSize
        self.imageType = imageType
        self.isLoading = isLoading
        self.isDisabled = isDisabled
    }
    func setIsLoading(isLoading: Bool) {
        self.isLoading = isLoading
    }
    func setIsDisabled(isDisabled: Bool) {
        self.isDisabled = isDisabled
    }
    func copy(with zone: NSZone? = nil) -> ImageData {
        return ImageData(image: image, imageSize: imageSize, imageType: imageType)
    }

    func stringInfo() -> String {
        return "imageSize: \(imageSize), imageType: \(imageType), isLoading: \(isLoading)"
    }

    func printInfo() {
        print(stringInfo())
    }
}

@MainActor
class ImagePicker: ObservableObject {
    @Published var images: [ImageData] = []
    @Published var imageSelections: [PhotosPickerItem] = [] {
        didSet {
            Task {
                if !imageSelections.isEmpty {
//                    print("HERE")
                    try await loadTransferable(from: imageSelections)
                } else {
                    self.images = []
                }
            }
        }
    }

    func updateImages(at index: Int, with newImageData: ImageData) {
        images[index] = newImageData
    }

    func loadTransferable(from imageSelection: [PhotosPickerItem]) async throws {
        do {
            self.images = []
            for imageSelection in imageSelections {
                if let data = try await imageSelection.loadTransferable(type: Data.self) {
                    if let uiImage = UIImage(data: data) {
                        self.images = self.images + [ImageData(image: uiImage, imageSize: getSizeMb(data: data), imageType: ImageFormat.get(from: data).rawValue)]
//                        self.images.append(ImageData(image: uiImage, imageSize: getSizeMb(data: data), imageType: ImageFormat.get(from: data).rawValue))
                    }
                }
            }
//            self.printImages()
        }
    }

    func reset() {
        self.images = []
        self.imageSelections = []
    }

    func printImages() {
        if images.count != 0 {
            for image in images {
                image.printInfo()
            }
        }
    }

    func stringImages() -> String {
        if images.count == 0 {
            return "IMAGES EMPTY"
        } else {
            var res = ""
            for image in images {
                res += image.stringInfo() + "\n"
            }
            return res
        }
    }
}

enum ImageFormat: String {
    case png, jpg, gif, tiff, webp, heic, unknown
}

extension ImageFormat {
    static func get(from data: Data) -> ImageFormat {
        switch data[0] {
        case 0x89:
            return .png
        case 0xFF:
            return .jpg
        case 0x47:
            return .gif
        case 0x49, 0x4D:
            return .tiff
        case 0x52 where data.count >= 12:
            let subdata = data[0...11]

            if let dataString = String(data: subdata, encoding: .ascii),
                dataString.hasPrefix("RIFF"),
                dataString.hasSuffix("WEBP")
            {
                return .webp
            }

        case 0x00 where data.count >= 12:
            let subdata = data[8...11]

            if let dataString = String(data: subdata, encoding: .ascii),
                Set(["heic", "heix", "hevc", "hevx"]).contains(dataString)
            {
                return .heic
            }
        default:
            break
        }
        return .unknown
    }

    var contentType: String {
        return "image/\(rawValue)"
    }
}
