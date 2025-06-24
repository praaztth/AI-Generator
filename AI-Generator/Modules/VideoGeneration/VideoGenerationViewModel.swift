//
//  VideoGenerationViewModel.swift
//  AI-Generator
//
//  Created by катенька on 24.06.2025.
//

import Foundation
import RxSwift
import RxCocoa

protocol VideoGenerationViewModelInputs {
    var didCloseView: PublishRelay<Void> { get }
}

protocol VideoGenerationViewModelOutputs {
    var generationFinished: Observable<URL> { get }
}

protocol VideoGenerationViewModelToView {
    var input: VideoGenerationViewModelInputs { get }
    var output: VideoGenerationViewModelOutputs { get }
}

class VideoGenerationViewModel: ViewModelConfigurable, VideoGenerationViewModelInputs, VideoGenerationViewModelOutputs, VideoGenerationViewModelToView {
    private let apiService: PixVerseAPIServiceProtocol
    private let storageService: UserDefaultsServiceProtocol
    private let disposeBag = DisposeBag()
    
    var input: VideoGenerationViewModelInputs { self }
    var output: VideoGenerationViewModelOutputs { self }
    
    // ViewController Inputs
    var didCloseView = PublishRelay<Void>()
    
    // Coordinator Outputs
    private let _generationFinished = PublishSubject<URL>()
    var generationFinished: Observable<URL> {
        _generationFinished.asObservable()
    }
    
    init(apiService: PixVerseAPIServiceProtocol, storageService: UserDefaultsServiceProtocol, generateBy: GenerateBy) {
        self.apiService = apiService
        self.storageService = storageService
//        self.apiService = MockApiService()
//        self.storageService = MockStorageService()
        
        switch generateBy {
        case .imageTemplate(let imageData, let imageName, let templateID):
            GenerationFlowHelper.createGenerationFlow(
                imageData: imageData,
                imageName: imageName,
                prompt: nil,
                templateID: templateID,
                apiService: self.apiService,
                storageService: self.storageService
            ) {
                return self.apiService.generateFromTemplate(templateID: templateID, imageData: imageData, imageName: imageName)
                    .asObservable()
            }
            .subscribe(onNext: { videoURL in
                guard let url = URL(string: videoURL) else {
                    self._generationFinished.onError(PixVerseAPIError.notFound)
                    return
                }
                DispatchQueue.main.async {
                    self._generationFinished.onNext(url)
                }
            }, onError: { error in
                self._generationFinished.onError(error)
                print("\(#file): Error while generating video:\(error)")
            })
            .disposed(by: disposeBag)
        case .promptAndImage(let imageData, let imageName, let prompt):
            GenerationFlowHelper.createGenerationFlow(
                imageData: imageData,
                imageName: imageName,
                prompt: prompt,
                templateID: nil,
                apiService: self.apiService,
                storageService: self.storageService
            ) {
                return self.apiService.generateFromPromptAndImage(prompt: prompt, imageData: imageData, imageName: imageName)
                    .asObservable()
            }
            .subscribe(onNext: { videoURL in
                guard let url = URL(string: videoURL) else {
                    self._generationFinished.onError(PixVerseAPIError.notFound)
                    return
                }
                DispatchQueue.main.async {
                    self._generationFinished.onNext(url)
                }
            }, onError: { error in
                self._generationFinished.onError(error)
                print("\(#file): Error while generating video:\(error)")
            })
            .disposed(by: disposeBag)
        case .prompt(let prompt):
            GenerationFlowHelper.createGenerationFlow(
                imageData: nil,
                imageName: nil,
                prompt: prompt,
                templateID: nil,
                apiService: self.apiService,
                storageService: self.storageService
            ) {
                return self.apiService.generateFromPrompt(prompt: prompt)
                    .asObservable()
            }
            .subscribe(onNext: { videoURL in
                guard let url = URL(string: videoURL) else {
                    self._generationFinished.onError(PixVerseAPIError.notFound)
                    return
                }
                DispatchQueue.main.async {
                    self._generationFinished.onNext(url)
                }
            }, onError: { error in
                self._generationFinished.onError(error)
                print("\(#file): Error while generating video:\(error)")
            })
            .disposed(by: disposeBag)
        }
    }
    
    func setupBindings() {
        
    }
}

class MockApiService: PixVerseAPIServiceProtocol {
    var generatedVideos: [Int: GeneratedVideo] = [:]
    let disposeBag = DisposeBag()
    
    func fetchTemplates() -> RxSwift.Single<TemplateResponse> {
        let data = """
            {"app_id":"com.test.test","templates":[{"prompt":"One click to send your kiss","name":"Kiss Kiss","category":"Trending","is_active":true,"preview_small":"https://api-use-core.store/static/video/small/d78624dd73014d71b10870054fcbce52.mp4","preview_large":"https://api-use-core.store/static/video/large/3e5346fbff66465ba86509f1393bbcfc.mp4","id":137,"template_id":315446315336768},{"prompt":"Show off your strong muscles and have everyone hooked.","name":"Muscle Surge","category":"Trending","is_active":true,"preview_small":"https://api-use-core.store/static/video/small/b17d85208f1548d8b0db0fd086b0b3ae.mp4","preview_large":"https://api-use-core.store/static/video/large/401f5debfa3d4cdd8c21a04edcaeea9b.mp4","id":140,"template_id":308621408717184},{"prompt":"Hug each other\t","name":"Hug Your Love","category":"Trending","is_active":true,"preview_small":"https://api-use-core.store/static/video/small/468a7d6ed786441a80b8f9b02175e5d6.mp4","preview_large":"https://api-use-core.store/static/video/large/f84aefb2c90b4fc1b3cdf637437dc8a0.mp4","id":149,"template_id":303624424723200}],"id":1}
        """.data(using: .utf8)
        return Single<TemplateResponse>.create { single in
            do {
                let templateResponse = try JSONDecoder().decode(TemplateResponse.self, from: data!)
                single(.success(templateResponse))
            } catch {
                single(.failure(PixVerseAPIError.decodingError("error")))
                print(PixVerseAPIError.decodingError("error"))
            }
            
            return Disposables.create {}
        }
    }
    
    func generateFromTemplate(templateID: String, imageData: Data, imageName: String) -> RxSwift.Single<GenerationRequest> {
        return Single.create { single in
            let videoID = Int.random(in: 100...999)
            single(.success(GenerationRequest(video_id: videoID, detail: "success")))
            let generatedVideo = GeneratedVideo(status: "generating", video_url: "")
            self.generatedVideos[videoID] = generatedVideo
            
            Observable<Int>.timer(.seconds(10), scheduler: ConcurrentDispatchQueueScheduler(qos: .background))
                .subscribe(onNext: { _ in
                    let generatedVideo = GeneratedVideo(status: "success", video_url: "https://api-use-core.store/static/video/large/3c81864e2f164799a522873170e783d7.mp4")
                    print("get request from server, video generated")
                    self.generatedVideos[videoID] = generatedVideo
                })
                .disposed(by: self.disposeBag)
            
            return Disposables.create {}
        }
    }
    
    func observeVideoGenerationStatus(videoID: String) -> Observable<(String, GeneratedVideo)> {
        return Observable<Int>.interval(.seconds(2), scheduler: ConcurrentDispatchQueueScheduler(qos: .background))
            .flatMapLatest { _ -> Observable<(String, GeneratedVideo)> in
                self.checkPendingRequest(requestID: videoID)
                    .map { (videoID, $0) }
            }
            .share()
    }
    
    func generateFromPrompt(prompt: String) -> RxSwift.Single<GenerationRequest> {
        Observable.empty().asSingle()
    }
    
    func generateFromPromptAndImage(prompt: String, imageData: Data, imageName: String) -> Single<GenerationRequest> {
        Observable.empty().asSingle()
    }
    
    func checkPendingRequest(requestID: String) -> RxSwift.Observable<GeneratedVideo> {
        let response = generatedVideos[Int(requestID)!]
        return Observable.just(response!)
    }
}

class MockStorageService: UserDefaultsServiceProtocol {
    var hasCompletedOnboarding: Bool = false
    
    func saveRequest(_ request: GenerationRequest) {}
    
    func getRequest(videoID: Int) -> GenerationRequest? {
        return nil
    }
    
    func getAllRequests() -> [GenerationRequest] {
        []
    }
    
    func removeRequest(videoID: Int) {}
    
    func saveGeneratedVideo(_ generatedVideo: GeneratedVideo) {}
    
    func getGeneratedVideo(url: String) -> GeneratedVideo? { nil }
    
    func removeGeneratedVideo(url: String) {}
}
