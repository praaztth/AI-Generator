//
//  VideoResultViewModel.swift
//  AI-Generator
//
//  Created by катенька on 23.06.2025.
//

import Foundation
import RxSwift
import RxCocoa
import Photos

protocol VideoResultViewModelInputs {
    var didSaveTapped: PublishRelay<Void> { get }
    var didCloseView: BehaviorSubject<Bool> { get }
    
}

protocol VideoResultViewModelOutputs {
    var videoURL: Driver<URL> { get }
}

protocol VideoResultViewModelToView {
    var input: VideoResultViewModelInputs { get }
    var output: VideoResultViewModelOutputs { get }
}

class VideoResultViewModel: BaseViewModel, VideoResultViewModelInputs, VideoResultViewModelOutputs, VideoResultViewModelToView {
    private let storageService: UserDefaultsServiceProtocol
    private let disposeBag = DisposeBag()
    
    var input: VideoResultViewModelInputs { self }
    var output: VideoResultViewModelOutputs { self }
    
    let _videoURL: BehaviorRelay<URL>
    var videoURL: Driver<URL> {
        _videoURL.asDriver()
    }
    var didSaveTapped = PublishRelay<Void>()
    var didCloseView = BehaviorSubject<Bool>(value: false)
    
    init(videoURL: URL, storageService: UserDefaultsServiceProtocol) {
        self._videoURL = BehaviorRelay(value: videoURL)
        self.storageService = storageService
        
        super.init()
    }
    
    override func setupBindings() {
        didSaveTapped
            .subscribe(onNext: {
                self._shouldShowLoading.accept(true)
                self.downloadVideo()
            })
            .disposed(by: disposeBag)
    }
    
    func downloadVideo() {
        let url = self._videoURL.value
        
        let task = URLSession.shared.downloadTask(with: url) { location, response, error in
            if let error = error {
                print("Failed while downloading data from url: \(error.localizedDescription)")
                return
            }
            
            guard let location = location else {
                print("Got nil location while downloading data")
                return
            }
            
            guard let localFileURL = self.copyToTemporaryDirectory(url: location) else { return }
            self.saveVideoToGallery(url: localFileURL)
        }
        
        task.resume()
    }
    
    func copyToTemporaryDirectory(url: URL) -> URL? {
        let tempDirectory = FileManager.default.temporaryDirectory
        let tempURL = tempDirectory.appendingPathComponent(UUID().uuidString, conformingTo: .mpeg4Movie)
        
        do {
            try FileManager.default.copyItem(at: url, to: tempURL)
            return tempURL
        } catch {
            print("Failed coping file to temporary directory: \(error)")
            return nil
        }
    }
    
    func saveVideoToGallery(url: URL) {
        PHPhotoLibrary.requestAuthorization(for: .addOnly) { status in
            guard status == .authorized else {
                print("Access to gallery denied")
                return
            }
            
            PHPhotoLibrary.shared().performChanges {
                let options = PHAssetResourceCreationOptions()
                PHAssetCreationRequest.forAsset().addResource(with: .video, fileURL: url, options: options)
            } completionHandler: { success, error in
                if success {
                    self._shouldShowLoading.accept(false)
                    print("The video saved successfully")
                } else {
                    print("Saving video failed: \(error?.localizedDescription ?? "unknown error")")
                }
            }
        }
    }
}
