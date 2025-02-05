//
//  Helper.swift
//  ImageCompress
//
//  Created by Tenzin Norden on 5/18/23.
//
import SwiftUI
import PhotosUI

// MARK: - Helper

let BUTTONHEIGHT: CGFloat = 56
let TEXTSIZE: CGFloat = 16

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

func deleteImages(images: [ImageData]) async {
    let imageSaver = ImageSaver2()
    for image in images {
        if !image.isDisabled {
            await imageSaver.deleteImage(image: image.uncompressedImage)
        }
    }
}

class ImageSaver2: NSObject {
    let imageSavingQueue = DispatchQueue(label: "com.yourapp.imagesaving")

//    MARK: - SAVEIMAGE IMAGESAVER
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

//    MARK: - DELETEIMAGE IMAGESAVER
    func deleteImage(image: PhotosPickerItem) async {
        let authorizationStatus = await PHPhotoLibrary.requestAuthorization(for: .readWrite)
        if authorizationStatus == .authorized {
            do {
                if (try await image.loadTransferable(type: Data.self)) != nil {
                    if let localID = image.itemIdentifier {
                        let result = PHAsset.fetchAssets(withLocalIdentifiers: [localID], options: nil)
                        if let asset = result.firstObject {
                            try await PHPhotoLibrary.shared().performChanges {
                                PHAssetChangeRequest.deleteAssets([asset] as NSFastEnumeration)
                            }
                        }
                    }
                }
            } catch {
                print(error)
            }
        }
    }
}

#Preview {
//    Progress(text: "Compressing", size: 15, color: Color.red)
    Shine(color: Color.red)
}


//
//struct ShareButton: View {
//    let images: [UIImage]
//
//    var body: some View {
//        Button(action: {
//            le activityViewController = UIActivityViewController(activityItems: images, applicationActivities: nil)
//            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
//                let window = windowScene.windows.first {
//                window.rootViewController?.present(activityViewController, animated: true, completion: nil)
//            }
////            UIApplication.shared.windows.first?.rootViewController?.present(activityViewController, animated: true, completion: nil)
//        }) {
//            Text("DEBUG")
//                .padding()
//                .background(Color.blue)
//                .foregroundColor(.white)
//                .cornerRadius(10)
//        }
//    }
//}

//struct ActivityViewController: UIViewControllerRepresentable {
//    let activityItems: [UIImage]
//    let applicationActivities: [UIActivity]? = nil
//
//    func makeUIViewController(context: Context) -> UIActivityViewController {
//        let copyImageItem = CopyImageActivityItem(imagesToCopy: activityItems)
//        let saveImageItem = SaveActivityItem(itemsToSave: activityItems)
//
//        // Add these custom activity items to the activityItems array
//        let allActivityItems = activityItems + [copyImageItem, saveImageItem]
//
//        let activityViewController = UIActivityViewController(
//            activityItems: allActivityItems,
//            applicationActivities: nil
//        )
//        return activityViewController
//    }
//
//    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {
//        // Nothing to do here
//    }
//}

//
//struct ActivityViewController: UIViewControllerRepresentable {
//    let activityItems: [UIImage]
//    let applicationActivities: [UIActivity]?
//
//    init(activityItems: [UIImage], applicationActivities: [UIActivity]? = nil) {
//        self.activityItems = activityItems
//        self.applicationActivities = applicationActivities
//    }
//
//    func makeUIViewController(context: Context) -> UIActivityViewController {
//        let copyImageItem = CopyImageActivityItem(imagesToCopy: activityItems)
//        let saveImageItem = SaveActivityItem(itemsToSave: activityItems)
//
//        // Add these custom activity items to the activityItems array
//        let allActivityItems = activityItems + [copyImageItem, saveImageItem]
//
//        let activityViewController = UIActivityViewController(
//            activityItems: allActivityItems,
//            applicationActivities: applicationActivities
//        )
//
//        // Create a custom SharePreviewViewController
//        let sharePreviewController = SharePreviewViewController(images: activityItems)
//
//        // Customize the preview for the "copyToPasteboard" activity
//        activityViewController.completionWithItemsHandler = { (activityType, completed, returnedItems, error) in
//            if let selectedActivity = activityType, selectedActivity == .copyToPasteboard {
//                // Customize the preview window for copying images
//                self.presentSharePreview(sharePreviewController, context: context)
//            }
//        }
//        presentSharePreview(sharePreviewController, context: context)
//        return activityViewController
//    }
//
//    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {
//        // Nothing to do here
//    }
//
//    func makeCoordinator() -> Coordinator {
//        return Coordinator()
//    }
//
//    private func presentSharePreview(_ previewController: UIViewController, context: Context) {
//        context.coordinator.hostingController.present(previewController, animated: true, completion: nil)
//    }
//
//    class Coordinator {
//        var hostingController: UIViewController!
//        var previewController: UIViewController?
//
//        init() {
//            self.hostingController = UIViewController()
//        }
//    }
//}
//
//class CopyImageActivityItem: NSObject, UIActivityItemSource {
//    let imagesToCopy: [UIImage]
//
//    init(imagesToCopy: [UIImage]) {
//        self.imagesToCopy = imagesToCopy
//        super.init()
//    }
//
//    func activityViewControllerPlaceholderItem(_ activityViewController: UIActivityViewController) -> Any {
//        // Return a single placeholder item, which can be a description or any valid object
//        return ""
//    }
//
//    func activityViewController(_ activityViewController: UIActivityViewController, itemForActivityType activityType: UIActivity.ActivityType?) -> Any? {
//        if activityType == .copyToPasteboard {
//            // Return the list of images as an array for "copyToPasteboard"
//            return imagesToCopy
//        }
//        return nil
//    }
//}
//
//class SaveActivityItem: NSObject, UIActivityItemSource {
//    let itemsToSave: [Any]
//
//    init(itemsToSave: [Any]) {
//        self.itemsToSave = itemsToSave
//        super.init()
//    }
//
//    func activityViewControllerPlaceholderItem(_ activityViewController: UIActivityViewController) -> Any {
//        // Return a placeholder item if needed (e.g., for MIME type)
//        return ""
//    }
//
//    func activityViewController(_ activityViewController: UIActivityViewController, itemForActivityType activityType: UIActivity.ActivityType?) -> Any? {
//        if activityType == UIActivity.ActivityType.saveToCameraRoll {
//            // Process and save items here, for example, save images to the camera roll
//            for item in itemsToSave {
//                if let image = item as? UIImage {
//                    UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
//                }
//            }
//        }
//        return nil
//    }
//}
//
//
//// Custom preview view controller to show images
//class ImagePreviewViewController: UIViewController {
//    let images: [UIImage]
//    let scrollView = UIScrollView()
//
//    init(images: [UIImage]) {
//        self.images = images
//        super.init(nibName: nil, bundle: nil)
//    }
//
//    required init?(coder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
//
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        scrollView.frame = view.bounds
//        scrollView.isPagingEnabled = true
//        scrollView.contentSize = CGSize(width: view.frame.size.width * CGFloat(images.count), height: view.frame.size.height)
//        view.addSubview(scrollView)
//        for (index, image) in images.enumerated() {
//            let imageView = UIImageView(image: image)
//            imageView.frame = CGRect(x: view.frame.size.width * CGFloat(index), y: 0, width: view.frame.size.width, height: view.frame.size.height)
//            imageView.contentMode = .scaleAspectFit
//            scrollView.addSubview(imageView)
//        }
//    }
//}
//
//class SharePreviewViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
//    var images: [UIImage]
//
//    init(images: [UIImage]) {
//        self.images = images
//        super.init(nibName: nil, bundle: nil)
//    }
//
//    required init?(coder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
//
//    private let tableView = UITableView()
//
//    override func viewDidLoad() {
//        super.viewDidLoad()
//
//        // Set up the table view
//        tableView.frame = view.bounds
//        tableView.delegate = self
//        tableView.dataSource = self
//        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
//        view.addSubview(tableView)
//    }
//
//    // UITableViewDataSource methods
//    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        return images.count
//    }
//
//    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
//        let image = images[indexPath.row]
//        cell.imageView?.image = image
//        return cell
//    }
//
//    // UITableViewDelegate method (if you want to handle row selection)
//    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        // Handle row selection if needed
//    }
//}
