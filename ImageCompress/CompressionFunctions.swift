//
//  CompressionFunctions.swift
//  ImageCompress
//
//  Created by Tenzin Norden on 7/8/23.
//

import Foundation
import PhotosUI

// MARK: - Deprecated
func compressImage(image: UIImage, targetSize: Int) -> Data? {
    guard let cgImage = image.cgImage else { return nil }
    let data = CFDataCreateMutable(kCFAllocatorDefault, 0)!
    let destination = CGImageDestinationCreateWithData(data, UTType.jpeg.identifier as CFString, 1, nil)!
    let options = [kCGImageDestinationLossyCompressionQuality: 0.5] as CFDictionary
    CGImageDestinationAddImage(destination, cgImage, options)
    CGImageDestinationFinalize(destination)
    let imageData = data as Data
//        print("imgSize \(imageData.count)")
//        print("targetSize \(targetSize * 1024 * 1024)")
    return imageData.count > (targetSize * 1024 * 1024) ? nil : imageData
}
func compressImage_my(image: ImageData, targetSize: Int) {
    var currSize: Double = image.imageSize
    var currImage: UIImage = image.image
    while(currSize > Double(targetSize)) {
//            print("running")
        let data = compressJpeg(image: currImage, quality: 0.0)!
        currSize = getSizeMb(data: data)
        currImage = UIImage(data: data)!
    }
//        print("ran at \(currSize) : \(Double(targetSize))")
    image.image = currImage
    image.imageSize = currSize
}

// MARK: - InUse Funcs
func compressImage_1(image: ImageData, targetSize: Int) -> ImageData {
    guard let cgImage = image.image.cgImage else { return image }
    let targetSizeInBytes = targetSize * 1024 * 1024
    var compressionQuality: CGFloat = 1.0
    var imageData: Data?
    while compressionQuality > 0 {
//            print("running at: \(compressionQuality)")
        let data = CFDataCreateMutable(kCFAllocatorDefault, 0)!
        let destination = CGImageDestinationCreateWithData(data, UTType.jpeg.identifier as CFString, 1, nil)!
        let options = [kCGImageDestinationLossyCompressionQuality: compressionQuality] as CFDictionary
        CGImageDestinationAddImage(destination, cgImage, options)
        CGImageDestinationFinalize(destination)
        imageData = data as Data
        if imageData!.count <= targetSizeInBytes {
            break
        }
        compressionQuality -= 0.1
    }
//        print("ran at \(getSizeMb(data: imageData!)) : \(Double(targetSize))")
    return ImageData(image: UIImage(data: imageData!)!, imageName: image.imageName, imageSize: getSizeMb(data: imageData!), imageType: image.imageType, isLoading: false, isDisabled: image.isDisabled)
}

// Currently In Use
func compressImage_2(image: ImageData, targetSize: Double) -> ImageData {
    let uiImage = image.image
    let imageData = uiImage.compress(to: targetSize)
//        print("ran at \(getSizeMb(data: imageData)) : \(Double(targetSize))")
    return ImageData(image: UIImage(data: imageData)!, imageName: image.imageName, imageSize: getSizeMb(data: imageData), imageType: image.imageType, isLoading: false, isDisabled: image.isDisabled)
}

func compressImage_3(image: ImageData, targetSize: Int) -> ImageData {
    let uiImage = image.image
    let imageData = uiImage.resizeToApprox(sizeInMB: Double(targetSize))
//        print("ran at \(getSizeMb(data: imageData)) : \(Double(targetSize))")
    return ImageData(image: UIImage(data: imageData)!, imageName: image.imageName, imageSize: getSizeMb(data: imageData), imageType: image.imageType, isLoading: false, isDisabled: image.isDisabled)
}

func compressImage_4(image: ImageData, targetSize: Int) -> ImageData {
    let uiImage = image.image
    let imageData = uiImage.resizeByByte(maxMb: targetSize);
//        print("ran at \(getSizeMb(data: imageData)) : \(Double(targetSize))")
    return ImageData(image: UIImage(data: imageData)!, imageName: image.imageName, imageSize: getSizeMb(data: imageData), imageType: image.imageType, isLoading: false, isDisabled: image.isDisabled)
}
