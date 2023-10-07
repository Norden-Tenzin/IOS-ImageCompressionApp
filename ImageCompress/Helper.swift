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

func openAppSettings() {
    if let appSettingsURL = URL(string: UIApplication.openSettingsURLString) {
        if UIApplication.shared.canOpenURL(appSettingsURL) {
            UIApplication.shared.open(appSettingsURL, options: [:], completionHandler: nil)
        }
    }
}

func downloadImages(images: [ImageData], albumName: String) {
    let imageSaver = ImageSaver2()
    if imageSaver.getAlbum(name: albumName) == nil {
        imageSaver.createAlbum(name: albumName) { album in
            if album != nil {
                saveImages(images: images, toAlbum: albumName, withImageSaver: imageSaver)
            }
        }
    } else {
        saveImages(images: images, toAlbum: albumName, withImageSaver: imageSaver)
    }
}

func saveImages(images: [ImageData], toAlbum albumName: String, withImageSaver imageSaver: ImageSaver2) {
    for image in images {
        if !image.isDisabled {
            imageSaver.saveToAlbum(image: image.image, albumName: albumName)
        }
    }
}

class ImageSaver: NSObject {
    func saveToAlbum(image: UIImage) {
        UIImageWriteToSavedPhotosAlbum(image, self, #selector(saveCompleted), nil)
    }
    @objc func saveCompleted(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
        print("Save finished!")
    }
}

class ImageSaver2: NSObject {
    let imageSavingQueue = DispatchQueue(label: "com.yourapp.imagesaving")

    func saveToAlbum(image: UIImage, albumName: String) {
        imageSavingQueue.async {
            if let album = self.getAlbum(name: albumName) {
                self.saveImage(image: image, album: album)
            } else {
                self.createAlbum(name: albumName) { album in
                    if let album = album {
                        self.saveImage(image: image, album: album)
                    }
                }
            }
        }
    }

    func getAlbum(name: String) -> PHAssetCollection? {
        let fetchOptions = PHFetchOptions()
        fetchOptions.predicate = NSPredicate(format: "title = %@", name)
        let collections = PHAssetCollection.fetchAssetCollections(with: .album, subtype: .any, options: fetchOptions)
        if let album = collections.firstObject {
            print("Fetched album with local identifier: \(album.localIdentifier)")
        }
        return collections.firstObject
    }

    func createAlbum(name: String, completion: @escaping (PHAssetCollection?) -> ()) {
        var placeholder: PHObjectPlaceholder?
        PHPhotoLibrary.shared().performChanges({
            let createAlbumRequest = PHAssetCollectionChangeRequest.creationRequestForAssetCollection(withTitle: name)
            placeholder = createAlbumRequest.placeholderForCreatedAssetCollection
        }, completionHandler: { success, error in
                if success {
                    let fetchResult = PHAssetCollection.fetchAssetCollections(withLocalIdentifiers: [placeholder!.localIdentifier], options: nil)
                    if let album = fetchResult.firstObject {
                        print("Created album with local identifier: \(album.localIdentifier)")
                    }
                    completion(fetchResult.firstObject)
                } else {
                    completion(nil)
                }
            }
        )
    }


    func saveImage(image: UIImage, album: PHAssetCollection) {
        PHPhotoLibrary.shared().performChanges({
            let creationRequest = PHAssetChangeRequest.creationRequestForAsset(from: image)
            let addAssetRequest = PHAssetCollectionChangeRequest(for: album)
            addAssetRequest?.addAssets([creationRequest.placeholderForCreatedAsset!] as NSArray)
        }, completionHandler: { success, error in
                if success {
                    print("Added image to album")
                } else {
                    print("Error adding image to album: \(String(describing: error))")
                }
            }
        )
    }
}

//func checkGalleryPermission()
//{
//    let authStatus = PHPhotoLibrary.authorizationStatus()
//    switch authStatus
//    {
//    case .denied: print("denied status")
//        let alert = UIAlertController(title: "Error", message: "Photo library status is denied", preferredStyle: .alert)
//        let cancelaction = UIAlertAction(title: "Cancel", style: .default)
//        let settingaction = UIAlertAction(title: "Setting", style: UIAlertAction.Style.default) { UIAlertAction in
//            if let url = URL(string: UIApplication.openSettingsURLString) {
//                UIApplication.shared.open(url, options: [:], completionHandler: { _ in })
//            }
//        }
//        alert.addAction(cancelaction)
//        alert.addAction(settingaction)
//        Viewcontoller.present(alert, animated: true, completion: nil)
//        break
//    case .authorized: print("success")
//        //open gallery
//        break
//    case .restricted: print("user dont allowed")
//        break
//    case .notDetermined: PHPhotoLibrary.requestAuthorization({ (newStatus) in
//            if (newStatus == PHAuthorizationStatus.authorized) {
//                print("permission granted")
//                //open gallery
//            }
//            else {
//                print("permission not granted")
//            }
//        })
//        break
//    case .limited:
//        print("limited")
//    @unknown default:
//        break
//    }
//}
