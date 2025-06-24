//
//  ImagePickerHelper.swift
//  AI-Generator
//
//  Created by катенька on 24.06.2025.
//

import Foundation
import PhotosUI
import RxSwift
import RxCocoa

class ImagePickerHelper {
    static func handlePickedResults(result: PHPickerResult) -> Single<(UIImage, String)> {
        let itemProvider = result.itemProvider
        
        return Single.zip(
            itemProvider.rxLoadImage(),
            itemProvider.rxLoadImageName()
        )
        
//        var itemName: String? = nil
//        if itemProvider.hasItemConformingToTypeIdentifier(UTType.image.identifier) {
//            _ = itemProvider.loadFileRepresentation(for: .image) { [weak self] url, openInPlace, error in
//                guard error == nil, let url = url else {
//                    print("Ошибка загрузки: \(error?.localizedDescription ?? "Неизвестная ошибка")")
//                    return
//                }
//                
//                let fileName = url.lastPathComponent
//                itemName = fileName
//            }
//        }
//        
//        itemProvider.loadObject(ofClass: UIImage.self) { [weak self] image, error in
//            guard let image = image as? UIImage,
//                  error == nil else {
//                return
//            }
//            
//            DispatchQueue.main.async {
//                self?.viewModel.setImageData(image: image)
//                self?.customView.setSelectedImage(image: image)
//            }
//        }
    }
}
