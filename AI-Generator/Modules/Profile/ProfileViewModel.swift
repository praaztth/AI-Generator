//
//  ProfileViewModel.swift
//  AI-Generator
//
//  Created by катенька on 25.06.2025.
//

import Foundation
import UIKit
import RxSwift
import RxCocoa
import AVFoundation

protocol ProfileViewModelInputs {
    var sectionedVideosDriver: Driver<[SectionOfVideos]> { get }
}

protocol ProfileViewModelOutputs {
    var loadTrigger: PublishRelay<Void> { get }
    var didTapSettings: PublishRelay<Void> { get }
    var didSelectVideo: PublishRelay<GeneratedVideoCellModel> { get }
}

protocol ProfileViewModelToView {
    var input: ProfileViewModelInputs { get }
    var output: ProfileViewModelOutputs { get }
}

protocol ProfileViewModelToCoordinator: ViewModelToCoordinator {
    var shouldOpenSettings: Driver<Void> { get }
    var shouldOpenVideo: Driver<URL> { get }
}

class ProfileViewModel: BaseViewModel, ProfileViewModelInputs, ProfileViewModelOutputs, ProfileViewModelToView, ProfileViewModelToCoordinator {
    private let apiService: PixVerseAPIServiceProtocol
    private let storageService: UserDefaultsServiceProtocol
    private let disposeBag = DisposeBag()
    
    var input: ProfileViewModelInputs { self }
    var output: ProfileViewModelOutputs { self }
    
    // ViewController Inputs
    private var _sectionedVideos = PublishSubject<[SectionOfVideos]>()
    var sectionedVideosDriver: Driver<[SectionOfVideos]> {
        _sectionedVideos
            .asDriver(onErrorJustReturn: [])
    }
    
    // ViewController Outputs
    var loadTrigger = PublishRelay<Void>()
    var didTapSettings = PublishRelay<Void>()
    var didSelectVideo = PublishRelay<GeneratedVideoCellModel>()
    
    // Coordinator Inputs
    private let _shouldOpenSettings = PublishRelay<Void>()
    var shouldOpenSettings: Driver<Void> {
        _shouldOpenSettings.asDriver(onErrorJustReturn: ())
    }
    
    private let _shouldOpenVideo = PublishRelay<URL>()
    var shouldOpenVideo: Driver<URL> {
        _shouldOpenVideo.asDriver(onErrorJustReturn: URL(string: "https://example.com")!)
    }
    
    init(apiService: PixVerseAPIServiceProtocol, storageService: UserDefaultsServiceProtocol) {
        self.apiService = apiService
        self.storageService = storageService
        super.init()
    }
    
    override func setupBindings() {
        loadTrigger
            .subscribe(onNext: {
                self.loadGeneratedVideos()
            })
            .disposed(by: disposeBag)
        
        didTapSettings
            .bind(to: _shouldOpenSettings)
            .disposed(by: disposeBag)
        
        didSelectVideo
            .map { $0.videoURL }
            .bind(to: _shouldOpenVideo)
            .disposed(by: disposeBag)
    }
    
    func loadGeneratedVideos() {
        _shouldShowLoading.accept(true)
        
        let generatedVideos = storageService.getAllGeneratedVideos()
        let thumbnailSingles: [Single<GeneratedVideoCellModel>] = generatedVideos
            .compactMap { video -> Single<GeneratedVideoCellModel>? in
                guard let stringURL = video.video_url,
                      let url = URL(string: stringURL) else { return nil }
                return generateThumbnail(from: url)
            }
        
        Single.zip(thumbnailSingles)
            .subscribe(onSuccess: { [weak self] elements in
                self?._sectionedVideos.onNext([SectionOfVideos(items: elements)])
                self?._shouldShowLoading.accept(false)
            }, onFailure: { error in
                print(error)
            })
            .disposed(by: disposeBag)
    }
    
    func generateThumbnail(from url: URL) -> Single<GeneratedVideoCellModel> {
        return Single.create { single in
            let asset = AVURLAsset(url: url)
            let imageGenerator = AVAssetImageGenerator(asset: asset)
            imageGenerator.appliesPreferredTrackTransform = true
            
            let time = CMTime(seconds: 1, preferredTimescale: 600)
            
            imageGenerator.generateCGImageAsynchronously(for: time) { cgImage, _, error in
                if let error = error {
                    single(.failure(NSError(domain: "Error generating thumbnail: \(error.localizedDescription)", code: -1)))
                    return
                }
                
                guard let cgImage = cgImage else {
                    single(.failure(NSError(domain: "Empty cgImage after generation thumbnail", code: -1)))
                    return
                }
                
                let image = UIImage(cgImage: cgImage)
                let model = GeneratedVideoCellModel(previewImage: image, videoURL: url)
                single(.success(model))
            }
            
            return Disposables.create {}
        }
    }
}
