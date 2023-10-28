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
    var uncompressedImage: PhotosPickerItem
    var imageName: String
    var imageSize: Double
    var imageType: String
    var isLoading: Bool
    var isDisabled: Bool

    init(image: UIImage, uncompressedImage: PhotosPickerItem, imageName: String, imageSize: Double, imageType: String) {
        self.image = image
        self.uncompressedImage = uncompressedImage
        self.imageName = imageName
        self.imageSize = imageSize
        self.imageType = imageType
        self.isLoading = false
        self.isDisabled = false
    }
    init(image: UIImage, uncompressedImage: PhotosPickerItem, imageName: String, imageSize: Double, imageType: String, isLoading: Bool, isDisabled: Bool) {
        self.image = image
        self.uncompressedImage = uncompressedImage
        self.imageName = imageName
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
        return ImageData(image: image, uncompressedImage: uncompressedImage, imageName: imageName, imageSize: imageSize, imageType: imageType)
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

    func loadTransferable(from imageSelections: [PhotosPickerItem]) async throws {
        do {
            self.images = []
            for imageSelection in imageSelections {
                if let data = try await imageSelection.loadTransferable(type: Data.self) {
                    var fileName: String = ""
                    var fileType: String = ""
                    if let localID = imageSelection.itemIdentifier {
                        let result = PHAsset.fetchAssets(withLocalIdentifiers: [localID], options: nil)
                        if let asset = result.firstObject {
                            let resources = PHAssetResource.assetResources(for: asset)
                            for resource in resources {
                                if resource.type == .photo {
                                    let originalFilename = resource.originalFilename
                                    fileName = (originalFilename as NSString).deletingPathExtension
                                    fileType = (originalFilename as NSString).pathExtension
                                }
                            }
                        }
                    }
                    if let uiImage = UIImage(data: data) {
                        self.images = self.images + [ImageData(image: uiImage, uncompressedImage: imageSelection, imageName: fileName, imageSize: getSizeMb(data: data), imageType: fileType)]
                    }
                }
            }
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
        print(data.count)
        switch data[0] {
        case 0x89:
            return .png
        case 0xFF:
            print(data[0])
            print("IN JPEG")
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
            let subdata = data[4...5]

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



//protocol Transferable {
//    func transfer(to destination: Transferable) throws
//    // Add any other required methods or properties here
//}
//
//class ImageData: ObservableObject, Identifiable, Transferable {
//    static func == (lhs: ImageData, rhs: ImageData) -> Bool {
//        lhs.id == rhs.id
//    }
//
//    var id: UUID = UUID()
//    var image: UIImage
//    var imageName: String
//    var imageSize: Double
//    var imageType: String
//    var isLoading: Bool
//    var isDisabled: Bool
//
//    init(image: UIImage, imageName: String, imageSize: Double, imageType: String) {
//        self.image = image
//        self.imageName = imageName
//        self.imageSize = imageSize
//        self.imageType = imageType
//        self.isLoading = false
//        self.isDisabled = false
//    }
//
//    init(image: UIImage, imageName: String, imageSize: Double, imageType: String, isLoading: Bool, isDisabled: Bool) {
//        self.image = image
//        self.imageName = imageName
//        self.imageSize = imageSize
//        self.imageType = imageType
//        self.isLoading = isLoading
//        self.isDisabled = isDisabled
//    }
//
//    func setIsLoading(isLoading: Bool) {
//        self.isLoading = isLoading
//    }
//
//    func setIsDisabled(isDisabled: Bool) {
//        self.isDisabled = isDisabled
//    }
//
//    func copy(with zone: NSZone? = nil) -> ImageData {
//        return ImageData(image: image, imageName: imageName, imageSize: imageSize, imageType: imageType)
//    }
//
//    func stringInfo() -> String {
//        return "imageSize: \(imageSize), imageType: \(imageType), isLoading: \(isLoading)"
//    }
//
//    func printInfo() {
//        print(stringInfo())
//    }
//
//    // Implement the transfer method to transfer data to another ImageData instance
//    func transfer(to destination: Transferable) throws {
//        guard let destinationImageData = destination as? ImageData else {
//            throw TransferError.incompatibleTypes
//        }
//
//        // Implement your data transfer logic here
//        destinationImageData.image = self.image
//        destinationImageData.imageName = self.imageName
//        destinationImageData.imageSize = self.imageSize
//        destinationImageData.imageType = self.imageType
//        destinationImageData.isLoading = self.isLoading
//        destinationImageData.isDisabled = self.isDisabled
//    }
//}
//
//enum TransferError: Error {
//    case incompatibleTypes
//}
