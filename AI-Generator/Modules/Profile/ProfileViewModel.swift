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
}

protocol ProfileViewModelToView {
    var input: ProfileViewModelInputs { get }
    var output: ProfileViewModelOutputs { get }
}

protocol ProfileViewModelToCoordinator {
    
}

class ProfileViewModel: ViewModelConfigurable, ProfileViewModelInputs, ProfileViewModelOutputs, ProfileViewModelToView, ProfileViewModelToCoordinator {
    private let apiService: PixVerseAPIServiceProtocol
    private let storageService: UserDefaultsServiceProtocol
    private let disposeBag = DisposeBag()
    
    var input: ProfileViewModelInputs { self }
    var output: ProfileViewModelOutputs { self }
    
    // ViewController Inputs
    private let _sectionedVideos = PublishRelay<[SectionOfVideos]>()
    var sectionedVideosDriver: Driver<[SectionOfVideos]> {
        _sectionedVideos
            .asDriver(onErrorJustReturn: [])
    }
    
    // ViewController Outputs
    var loadTrigger = PublishRelay<Void>()
    
    // Coordinator Inputs
    
    init(apiService: PixVerseAPIServiceProtocol, storageService: UserDefaultsServiceProtocol) {
        self.apiService = apiService
        self.storageService = storageService
        
        setupBindings()
    }
    
    func setupBindings() {
        loadTrigger.subscribe(onNext: {
            self.loadGeneratedVideos()
        })
        .disposed(by: disposeBag)
    }
    
    func loadGeneratedVideos() {
        let generatedVideos = storageService.getAllGeneratedVideos()
        
        let videoCellModels = generatedVideos
            .compactMap { video -> GeneratedVideoCellModel? in
                guard let stringUrl = video.video_url,
                      let url = URL(string: stringUrl) else { return nil }
                return GeneratedVideoCellModel(previewImage: UIImage(), videoURL: url)
            }
        
        _sectionedVideos.accept([SectionOfVideos(items: videoCellModels)])
    }
    
    // TODO: use rx
    func generateThumbnail(from url: URL, completion: @escaping (UIImage?) -> Void) {
        let asset = AVURLAsset(url: url)
        let imageGenerator = AVAssetImageGenerator(asset: asset)
        imageGenerator.appliesPreferredTrackTransform = true
        
        let time = CMTime(seconds: 1, preferredTimescale: 600)
        
        imageGenerator.generateCGImageAsynchronously(for: time) { cgImage, _, error in
            if let error = error {
                print("Error generating thumbnail: \(error)")
                completion(nil)
                return
            }
            
            guard let cgImage = cgImage else {
                print("Empty cgImage after generation thumbnail")
                completion(nil)
                return
            }
            
            let image = UIImage(cgImage: cgImage)
            completion(image)
        }
    }
}
