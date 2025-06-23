//
//  UseEffectViewModel.swift
//  AI-Generator
//
//  Created by катенька on 20.06.2025.
//

import Foundation
import RxSwift
import RxCocoa

protocol UseEffectViewModelProtocol {
    var loadTrigger: PublishRelay<Void> { get }
    var didTapInputField: PublishRelay<Void> { get }
    var didTapCreateButton: PublishRelay<Void> { get }
    var didCloseView: BehaviorSubject<Bool> { get }
    var objectLoadedDriver: Driver<UseEffectModel?> { get }
    
    var showLoading: Driver<Void> { get }
    var generationFinished: Driver<URL> { get }
    
    func setImageName(name: String)
    func setImageData(image: UIImage)
}

class UseEffectViewModel: UseEffectViewModelProtocol {
    // TODO: make a video generation into a separate module
    private let effectID: String
    private var imageData: Data? = nil
    private var imageName: String? = nil
    private var generationRequestID: Int? = nil
    private let disposeBag = DisposeBag()
    
    private let apiService: PixVerseAPIServiceProtocol
    private let storageService: UserDefaultsServiceProtocol
    private let cacheService: CacheServiceProtocol
    
    private let _showLoading = PublishRelay<Void>()
    private let _generationFinished = PublishSubject<URL>()
    
    var selectedImage: Data?
    // TODO: remove view model logic from view, onNext only from here
    let loadTrigger = PublishRelay<Void>()
    let didTapInputField = PublishRelay<Void>()
    let didTapCreateButton = PublishRelay<Void>()
    let didCloseView = BehaviorSubject<Bool>(value: false)
    
    var showLoading: Driver<Void> {
        _showLoading.asDriver(onErrorJustReturn: ())
    }
    var generationFinished: Driver<URL> {
        _generationFinished.asDriver { _ in
            Driver.empty()
        }
    }
    
    lazy var objectLoadedDriver: Driver<UseEffectModel?> = {
        return loadTrigger.map { self.getTemplate() }
            .asDriver(onErrorJustReturn: nil)
    }()
    
    init(effectID: Int, apiService: PixVerseAPIServiceProtocol, storageSevice: UserDefaultsServiceProtocol, cacheService: CacheServiceProtocol) {
        self.effectID = String(effectID)
        self.apiService = apiService
        self.storageService = storageSevice
//        self.apiService = MockApiService()
//        self.storageService = MockStorageService()
        self.cacheService = cacheService
        
        bind()
    }
    
    // TODO: move checking timer logic to other layer
    func bind() {
        didTapCreateButton
            .asObservable()
            .do(onNext: { _ in
                self._showLoading.accept(())
            })
            .flatMapLatest { _ -> Observable<GenerationRequest> in
                guard let imageData = self.imageData,
                      let imageName = self.imageName else {
                    print("No image data or name")
                    return Observable.empty()
                }
                return self.apiService.generateFromTemplate(templateID: self.effectID, imageData: imageData, imageName: imageName)
                    .asObservable()
            }
            .flatMapLatest { generationRequest -> Observable<GeneratedVideo> in
                self.storageService.saveRequest(generationRequest)
                self.generationRequestID = generationRequest.video_id
                return Observable<Int>.interval(.seconds(5), scheduler: ConcurrentDispatchQueueScheduler(qos: .background))
                    .flatMapLatest { _ -> Observable<GeneratedVideo> in
                        self.apiService.checkPendingRequest(requestID: String(generationRequest.video_id))
                    }
                    .share()
            }
            .filter { $0.status == "success" }
            .take(1)
            .bind { generatedVideo in
                guard let url = URL(string: generatedVideo.video_url) else { return }
                self._generationFinished.onNext(url)
                self.storageService.saveGeneratedVideo(generatedVideo)
                if let id = self.generationRequestID {
                    self.storageService.removeRequest(videoID: id)
                }
            }
            .disposed(by: self.disposeBag)
    }
    
    func getTemplate() -> UseEffectModel? {
        guard let cachedObject = cacheService.getObject(forKey: String(effectID)) as? CachableTemplate else { return nil }
        let object = cachedObject.data
        let objectToDisplay = UseEffectModel(title: object.name, templateId: object.template_id, videoURL: URL(string: object.preview_large))
        return objectToDisplay
    }
    
    func setImageName(name: String) {
        self.imageName = name
    }
    
    func setImageData(image: UIImage) {
        self.imageData = image.jpegData(compressionQuality: 0.5)
        print("размер файла: \(imageData?.count ?? 0)")
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
                single(.failure(PixVerseAPIError.decodingError(error)))
                print(PixVerseAPIError.decodingError(error))
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
    
    func generateFromPrompt(prompt: String) -> Single<GenerationRequest> {
        return Single<GenerationRequest>.create { single in
            return Disposables.create()
        }
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
