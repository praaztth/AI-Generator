//
//  ProfileViewModel.swift
//  AI-Generator
//
//  Created by катенька on 25.06.2025.
//

import Foundation
import RxSwift
import RxCocoa
import AVFoundation

protocol ProfileViewModelInputs {
    var sectionedVideosDriver: Driver<[SectionOfVideos]> { get }
}

protocol ProfileViewModelOutputs {
    var loadTrigger: PublishRelay<Void> { get }
    var didTapSettings: PublishRelay<Void> { get }
}

protocol ProfileViewModelToView {
    var input: ProfileViewModelInputs { get }
    var output: ProfileViewModelOutputs { get }
}

protocol ProfileViewModelToCoordinator {
    var shouldOpenSettings: Driver<Void> { get }
}

class ProfileViewModel: ViewModelConfigurable, ProfileViewModelInputs, ProfileViewModelOutputs, ProfileViewModelToView, ProfileViewModelToCoordinator {
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
    
    // Coordinator Inputs
    private let _shouldOpenSettings = PublishRelay<Void>()
    var shouldOpenSettings: Driver<Void> {
        _shouldOpenSettings.asDriver(onErrorJustReturn: ())
    }
    
    init(apiService: PixVerseAPIServiceProtocol, storageService: UserDefaultsServiceProtocol) {
        self.apiService = apiService
        self.storageService = storageService
        
        setupBindings()
    }
    
    func setupBindings() {
        loadTrigger
            .subscribe(onNext: {
                self.loadGeneratedVideos()
            })
            .disposed(by: disposeBag)
        
        didTapSettings
            .bind(to: _shouldOpenSettings)
            .disposed(by: disposeBag)
    }
    
    func loadGeneratedVideos() {
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
