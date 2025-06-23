//
//  VideoResultViewModel.swift
//  AI-Generator
//
//  Created by катенька on 23.06.2025.
//

import Foundation
import RxSwift
import RxCocoa

protocol VideoResultViewModelInputs {
    var didSaveTapped: PublishRelay<Void> { get }
}

protocol VideoResultViewModelOutputs {
    var videoURL: Driver<URL> { get }
}

protocol VideoResultViewModelToView {
    var input: VideoResultViewModelInputs { get }
    var output: VideoResultViewModelOutputs { get }
}

class VideoResultViewModel: VideoResultViewModelInputs, VideoResultViewModelOutputs, VideoResultViewModelToView {
    private let storageService: UserDefaultsServiceProtocol
    private let disposeBag = DisposeBag()
    
    var input: VideoResultViewModelInputs { self }
    var output: VideoResultViewModelOutputs { self }
    
    let _videoURL: BehaviorRelay<URL>
    var videoURL: Driver<URL> {
        _videoURL.asDriver()
    }
    var didSaveTapped = PublishRelay<Void>()
    
    init(videoURL: URL, storageService: UserDefaultsServiceProtocol) {
        self._videoURL = BehaviorRelay(value: videoURL)
        self.storageService = storageService
        
        didSaveTapped
            .subscribe(onNext: {
                print("save button tapped")
            })
            .disposed(by: disposeBag)
    }
    
    
}
