//
//  Helper.swift
//  ImageCompress
//
//  Created by Tenzin Norden on 5/18/23.
//

import PhotosUI

// MARK: - Helper

func getSizeMb(data: Data) -> Double {
    return Double(data.count) / pow(2, 20)
}

func formatSizeMb(data: Data) -> String {
    let bcf = ByteCountFormatter()
    bcf.allowedUnits = [.useMB] // optional: restricts the units to MB only
    bcf.countStyle = .file
    let string = bcf.string(fromByteCount: Int64(data.count))
    return string
}

func compressJpeg(image: UIImage, quality: Double) -> Data? {
    let data = image.jpegData(compressionQuality: 0.5)
    return data
}
