//
//  ImagePicker.swift
//  EDYOU
//
//  Created by  Mac on 06/09/2021.
//

import UIKit
import MobileCoreServices
import PhotosUI
//import HXPHPicker
import SwiftMessages

struct PhoneMediaAssets {
    var image: UIImage?
    var videoData: Data?
    var thumbnailImage: UIImage?
    var videoDuration: Int = 0
    
    var fileName: String?
    var imageData: Data? {
        return image?.jpegData(compressionQuality: 0.5)
    }
    var isImage: Bool {
        return image != nil
    }
    var dimenstions : String?
    var videoURL : URL?
}
// Completion Blocks
typealias SingleImageCompletionBlock = ((_ image: UIImage, _ fileName: String) -> Void)
typealias MultipleImageCompletionBlock = ((_ image: [UIImage]) -> Void)
typealias MediaAssetCompletion = ((_ data: PhoneMediaAssets) -> Void)
typealias MediaAssetsCompletion = ((_ data: [PhoneMediaAssets]) -> Void)

class ImagePicker: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate, PHPickerViewControllerDelegate
{
    //MARK:- Properties
//    var calback: SingleImageCompletionBlock?
    var calbackWithMultiImages: ((_ image: [UIImage]) -> Void)?
//    var calbackWithUrl: ((_ data: Data, _ isImage: Bool) -> Void)?
    var mediaAssetCallback: MediaAssetCompletion?
    var mediaAssetsCallback: MediaAssetsCompletion?
    //MARK:- Signleton
    static var shared = ImagePicker()
    private override init() { super.init() }
    
    //MARK:- Methods
    func open(_ controller: UIViewController, title: String?, message: String?, completion: @escaping MediaAssetCompletion) {
        self.mediaAssetCallback = completion
        controller.view.endEditing(true)
        
        var sheetOptions: [String]?
        sheetOptions = ["Camera", "Gallery"]
        showActionSheet(sheetOptions: sheetOptions!, controller: controller, sheetTitle: title!)
        
//        let alert = UIAlertController(title: title, message: message, preferredStyle: Device.isPad ? .alert : .actionSheet)
//        let cameraAction = UIAlertAction(title: "Camera", style: .default) { (_) in
//            if UIImagePickerController.isSourceTypeAvailable(.camera) {
//                let picker = UIImagePickerController()
//                picker.delegate = self
//                picker.sourceType = .camera
//                picker.allowsEditing = true
//                picker.mediaTypes = Constants.imageMediaType
//                controller.present(picker, animated: true, completion: nil)
//            }
//        }
//        let galleryAction = UIAlertAction(title: "Gallery", style: .default) { (_) in
//            let picker = UIImagePickerController()
//            picker.delegate = self
//            picker.sourceType = .photoLibrary
//            picker.allowsEditing = true
//            picker.mediaTypes = Constants.imageMediaType
//            controller.present(picker, animated: true, completion: nil)
//        }
//        alert.addAction(cameraAction)
//        alert.addAction(galleryAction)
//        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
//        controller.present(alert, animated: true, completion: nil)
    }
    
    
    func showActionSheet( sheetOptions:[String], controller: UIViewController, sheetTitle: String ) {
       
        
        let genericPicker = ReusbaleOptionSelectionController(options:  sheetOptions, optionshasIcons: true,  previouslySelectedOption: "Male", screenName: "", completion: { selected in
            //self.selectedGender = selected
            if selected == "Camera" {
                if UIImagePickerController.isSourceTypeAvailable(.camera) {
                    let picker = UIImagePickerController()
                    picker.delegate = self
                    picker.sourceType = .camera
                    picker.allowsEditing = true
                    picker.mediaTypes = Constants.imageMediaType
                    controller.present(picker, animated: true, completion: nil)
                }
            } else if selected == "Gallery" {
                let picker = UIImagePickerController()
                picker.delegate = self
                picker.sourceType = .photoLibrary
                picker.allowsEditing = true
                picker.mediaTypes = Constants.imageMediaType
                controller.present(picker, animated: true, completion: nil)
            }
           
        })
        
        controller.presentPanModal(genericPicker)
    }
    
    func openCameraWithType(from controller: UIViewController, mediaType : [String], completion: @escaping MediaAssetCompletion) {
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            self.mediaAssetCallback = completion
            let picker = UIImagePickerController()
            picker.delegate = self
            picker.sourceType = .camera
            picker.allowsEditing = false
            picker.mediaTypes = mediaType
            controller.present(picker, animated: true, completion: nil)
        } 
    }
    
    func openGalleryWithType(from controller: UIViewController, mediaType : [String],allowEditing : Bool = true, completion: @escaping MediaAssetCompletion) {
        
        self.mediaAssetCallback = completion
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = .photoLibrary
        picker.allowsEditing = allowEditing
        picker.mediaTypes = mediaType
        
        picker.videoMaximumDuration = 120
        controller.present(picker, animated: true, completion: nil)
        
    }

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        var fileName = "IMAGE.png"
        if let asset = info[UIImagePickerController.InfoKey.phAsset] as? PHAsset {
            let resources = PHAssetResource.assetResources(for: asset)
            fileName = resources.first?.originalFilename ?? "IMAGE.png"
        }
        if fileName.replacingOccurrences(of: " ", with: "").isEmpty {
            fileName = "IMAGE.png"
        }
        //For Video
        var mediaAsset = PhoneMediaAssets()
        if let url = info[UIImagePickerController.InfoKey.mediaURL] as? URL, let data = try? Data(contentsOf: url) {
            PHPhotoLibrary.shared().performChanges {
                PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: url)
            }
            mediaAsset.videoURL = url
            mediaAsset.videoData = data
            mediaAsset.thumbnailImage = url.getThumbnailImage()
            mediaAsset.videoDuration = url.getVideoDuration()
            
            DispatchQueue.main.async {
                self.mediaAssetCallback?(mediaAsset)
                picker.dismiss(animated: true, completion: nil)
            }
            
            return
        }
        
               // For Image
        if let image = info[UIImagePickerController.InfoKey.editedImage] as? UIImage {
            mediaAsset.image = image
            mediaAsset.fileName = fileName
        } else if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            mediaAsset.image = image
            mediaAsset.fileName = fileName
        }
        
        PHPhotoLibrary.shared().performChanges {
            PHAssetChangeRequest.creationRequestForAsset(from: mediaAsset.image!)
                   } completionHandler: { success, error in
                       if success {
                           // Image saved successfully
                           // Now retrieve the PHAsset
                           DispatchQueue.main.async {
                               self.mediaAssetCallback?(mediaAsset)
                               picker.dismiss(animated: true, completion: nil)
                           }
                          
                          
                       } else {
                           // Handle error
//                           self.mediaAssetCallback?(mediaAsset)
                           DispatchQueue.main.async {
                               self.mediaAssetCallback?(mediaAsset)
                               picker.dismiss(animated: true, completion: nil)
                           }
                           print("Error saving image to photo library: \(error?.localizedDescription ?? "")")
                       }
                   }
       

    }
    
    func fetchAsset(for info: [UIImagePickerController.InfoKey: Any]) {
            // Retrieve the asset using the localIdentifier from the info dictionary
            if let localIdentifier = info[.imageURL] as? String {
                let fetchResult = PHAsset.fetchAssets(withLocalIdentifiers: [localIdentifier], options: nil)
                if let asset = fetchResult.firstObject {
                    // Use the PHAsset as needed
                    print("PHAsset retrieved: \(asset)")
                }
            }
        }
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
    
    func openGalleryWithTypeMultiplePick(from controller: UIViewController, mediaType : String, completion: @escaping MediaAssetsCompletion) {
        self.mediaAssetsCallback = completion
        var configuration = PHPickerConfiguration()
        configuration.filter = mediaType.lowercased() == "public.movie" ? .videos : .images
        configuration.selectionLimit = 10 // Set to 0 for unlimited selection
        let picker = PHPickerViewController(configuration: configuration)
        picker.delegate = self
        
        controller.present(picker, animated: true, completion: nil)
    }
    
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        
        
        
        
        let group = DispatchGroup()
        var mediaAssets = [PhoneMediaAssets]()
        results.forEach { result in
            
            
            
            group.enter()

                        getMedia(from: result) { mediaAsset in
                            if let media = mediaAsset{
                                mediaAssets.append(media)
                            }
                           
                            group.leave()
                        }
        }
        group.notify(queue: DispatchQueue.main) {
                    // Do something with the selected images
            self.mediaAssetsCallback?(mediaAssets)
        }

//            let group = DispatchGroup()

//            for result in results {
//                group.enter()
//
//                result.itemProvider.loadFileRepresentation(forTypeIdentifier: "public.image") { (url, error) in
//                    if let error = error {
//                        print("Error loading image: \(error.localizedDescription)")
//                    } else if let url = url, let image = UIImage(contentsOfFile: url.path) {
//                        images.append(image)
//                    }
//
//                    group.leave()
//                }
//            }

//            group.notify(queue: DispatchQueue.main) {
//                self.completionHandler?(images)
//            }

                    picker.dismiss(animated: true, completion: nil)
        }
    
    func getMedia(from result: PHPickerResult, completion: @escaping (PhoneMediaAssets?) -> Void) {
        var fileName = "IMAGE.png"
        var mediaAsset = PhoneMediaAssets(image: nil,fileName: fileName)
        guard result.itemProvider.canLoadObject(ofClass: UIImage.self) else {
            completion(mediaAsset)
            return
        }
        
        result.itemProvider.loadObject(ofClass: UIImage.self) { image, error in
            guard let image = image as? UIImage else {
                completion(mediaAsset)
                return
            }
            mediaAsset.image = image
            guard let assetIdentifier = result.assetIdentifier else {
                completion(mediaAsset)
                return
            }
            
            let fetchResult = PHAsset.fetchAssets(withLocalIdentifiers: [assetIdentifier], options: nil)
            
            guard let asset = fetchResult.firstObject else {
                mediaAsset.image = image
                completion(mediaAsset)
                return
            }
            if #available(iOS 15.0, *) {
                if let resource = PHAssetResource.assetResources(for: asset).first {
                    mediaAsset.fileName = resource.originalFilename
                }
            } else {
                let resources = PHAssetResource.assetResources(for: asset)
                let resource = resources.first(where: { $0.type == .photo })
                mediaAsset.fileName = resource?.originalFilename
            }
            
            completion(mediaAsset)
        }
    }
    func fetchAssetFromURL(_ fileURL: URL, completion: @escaping (PHAsset?) -> Void) {
        // Check if the asset exists in the photo library
        let fetchOptions = PHFetchOptions()
        fetchOptions.predicate = NSPredicate(format: "mediaType == %d", PHAssetMediaType.image.rawValue) // You can adjust the mediaType based on your asset type

        let fetchResult = PHAsset.fetchAssets(withALAssetURLs: [fileURL], options: fetchOptions)

        guard let asset = fetchResult.firstObject else {
            // Asset not found
            completion(nil)
            return
        }

        completion(asset)
    }
    
}

// MARK: - Save Media
extension ImagePicker {
    func saveImage(selectedImage:UIImage, showMessage: Bool = true){
        if showMessage {
            UIImageWriteToSavedPhotosAlbum(selectedImage, self, #selector(image(_:didFinishSavingWithError:contextInfo:)), nil)
        } else {
            UIImageWriteToSavedPhotosAlbum(selectedImage, nil, nil, nil)
        }
    }
    @objc func image(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
        if let error = error {
            // we got back an error!
            BaseController().showErrorWith(message: error.localizedDescription)
        } else {
            BaseController().showSuccessMessage(message: "Your image has been saved.")
        }
    }
}

// MARK: - HXPicker
extension ImagePicker {
    func openGalleryUsingHXPHImagePicker(from controller: UIViewController, completion: @escaping (_ mediaFiles: [Media]) -> Void)
    {
        let imagePicker = ImagePickerSetupClass()
        let config = imagePicker.setupConfigs()
        Photo.picker(
            config
            
        ) { result, pickerController in

            var mediaFiles = [Media]()
//            for index in 0 ..< result.photoAssets.count {
//                //get Name
//                var fileName = "IMAGE.png"
//                if let phAsset = result.photoAssets[index].phAsset {
//                    
//                    let resources = PHAssetResource.assetResources(for: phAsset)
//                    fileName = resources.first?.originalFilename ?? "IMAGE.png"
//                }
//                if fileName.replacingOccurrences(of: " ", with: "") == "" {
//                    fileName = "IMAGE.png"
//                }
//                //get Image
//                if result.photoAssets[index].mediaType == .photo {
//                    if let image = result.photoAssets[index].originalImage, let m = Media(withImage: image, key: "images",mediaImage: image)  {
//                        mediaFiles.append(m)
//                    }
//                }
//                else {
//                    //get video
//                    let currentIndex = index
//                    result.photoAssets[index].getVideoURL(completion: { res in
//                        switch res {
//                        case .success(let respone):
//                            print(respone.url)
//                            let url = respone.url
//                            if let data = try? Data(contentsOf: url) {
//                                let thumbnailImage = url.getThumbnailImage()
//                                let m = Media(withData: data,key: "videos", mimeType: .video,thumbnailImage: thumbnailImage,videoURL: url)
//                                mediaFiles.insert(m, at: currentIndex)
//                            }
//                            
//                        case .failure(_):
//                            break
//                        }
//                        print(res)
//                    })
//                }
//            }
            DispatchQueue.main.async {
                controller.startLoading(title: "Finalizing")
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                completion(mediaFiles)
            }
        } cancel: { pickerController in
            
        }
    }
}
