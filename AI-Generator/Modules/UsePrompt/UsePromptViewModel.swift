//
//  UsePromptViewModel.swift
//  AI-Generator
//
//  Created by катенька on 24.06.2025.
//

import Foundation
import RxSwift
import RxCocoa

protocol UsePromptViewModelInputs {
    
}

protocol UsePromptViewModelOutputs {
    var didTappedOpenPaywall: PublishRelay<Void> { get }
    var didTapCreate: PublishRelay<Void> { get }
    var promptToGenerate: PublishRelay<String?> { get }
}

protocol UsePromptViewModelToView {
    var input: UsePromptViewModelInputs { get }
    var output: UsePromptViewModelOutputs { get }
}

protocol UsePromptViewModelToCoordinator {
    var shouldOpenPaywall: Observable<Void> { get }
    var shouldGenerateVideo: Driver<GenerateBy> { get }
//    var generationFinished: Driver<URL> { get }
}

class UsePromptViewModel: ViewModelConfigurable, UsePromptViewModelInputs, UsePromptViewModelOutputs, UsePromptViewModelToView, UsePromptViewModelToCoordinator {
    private let apiService: PixVerseAPIServiceProtocol
    private let storageService: UserDefaultsServiceProtocol
    private let disposeBag = DisposeBag()
    private var prompt: String? = nil
    private var imageData: Data? = nil
    private var imageName: String? = nil
    
    var input: UsePromptViewModelInputs { self }
    var output: UsePromptViewModelOutputs { self }
    
    // ViewController outputs
    let didTappedOpenPaywall = PublishRelay<Void>()
    var didTapCreate = PublishRelay<Void>()
    let promptToGenerate = PublishRelay<String?>()
    
    // Coordinator inputs
    private let _shouldOpenPaywall = PublishRelay<Void>()
    var shouldOpenPaywall: Observable<Void> {
        _shouldOpenPaywall.asObservable()
    }
    private let _shouldGenerateVideo = PublishRelay<GenerateBy>()
    var shouldGenerateVideo: Driver<GenerateBy> {
        _shouldGenerateVideo.asDriver(onErrorJustReturn: .prompt(prompt: ""))
    }
    private let _generationFinished = PublishSubject<URL>()
    var generationFinished: Driver<URL> {
        _generationFinished.asDriver { _ in
            Driver.empty()
        }
    }
    
    init(apiService: PixVerseAPIServiceProtocol, storageService: UserDefaultsServiceProtocol) {
        self.apiService = apiService
        self.storageService = storageService
        
        setupBindings()
    }
    
    func setupBindings() {
        didTappedOpenPaywall
            .bind(to: _shouldOpenPaywall)
            .disposed(by: disposeBag)
        
        promptToGenerate
            .bind { text in
                self.prompt = text
            }
            .disposed(by: disposeBag)
        
        didTapCreate
            .subscribe(onNext: {
                guard let prompt = self.prompt else { return }
                
                if let imageData = self.imageData,
                   let imageName = self.self.imageName {
                    self._shouldGenerateVideo.accept(.promptAndImage(imageData: imageData, imageName: imageName, prompt: prompt))
                } else {
                    self._shouldGenerateVideo.accept(.prompt(prompt: prompt))
                }
            })
            .disposed(by: disposeBag)
        
        
//        promptToGenerate
//            .do(onNext: { _ in
//                self._showLoading.accept(())
//            })
//            .flatMapLatest { prompt -> Observable<GenerationRequest> in
//                self.apiService.generateFromPrompt(prompt: prompt)
//                    .asObservable()
//            }
//            .flatMapLatest { generationRequest -> Observable<GeneratedVideo> in
//                self.storageService.saveRequest(generationRequest)
//                self.generationRequestID = generationRequest.video_id
//                return Observable<Int>.interval(.seconds(5), scheduler: ConcurrentDispatchQueueScheduler(qos: .background))
//                    .flatMapLatest { _ -> Observable<GeneratedVideo> in
//                        self.apiService.checkPendingRequest(requestID: String(generationRequest.video_id))
//                    }
//                    .share()
//            }
//            .filter { $0.status == "success" || $0.status == "error" }
//            .take(1)
//            .subscribe(onNext: { generatedVideo in
//                guard let stringURL = generatedVideo.video_url,
//                      let url = URL(string: stringURL) else { return }
//                self._generationFinished.onNext(url)
//                self.storageService.saveGeneratedVideo(generatedVideo)
//                if let id = self.generationRequestID {
//                    self.storageService.removeRequest(videoID: id)
//                }
//            }, onError: { error in
//                print(error)
//            })
//            .disposed(by: self.disposeBag)
    }
}
