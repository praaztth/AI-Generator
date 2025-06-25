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

class GalleryPickerHelper {
    static func handlePickedResults<T: NSItemProviderReading>(ofType: T.Type, typeIdentifiers: [String], result: PHPickerResult) -> Single<(T, URL)> {
        let itemProvider = result.itemProvider
        
        return Single.zip(
            itemProvider.rxLoadMediaFile(ofType: T.self),
            itemProvider.rxLoadMediaFilePath(for: typeIdentifiers)
        )
    }
}
