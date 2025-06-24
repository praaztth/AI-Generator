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
    }
}
