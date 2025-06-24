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
    
    var shouldGenerateVideo: Driver<GenerateBy> { get }
    var showLoading: Driver<Void> { get }
    var generationFinished: Driver<URL> { get }
    
    func setImageName(name: String)
    func setImageData(image: UIImage)
}

class UseEffectViewModel: UseEffectViewModelProtocol {
    // TODO: make a video generation into a separate module
    private let effectID: String
//    private var imageData = BehaviorRelay<Data?>(value: nil)
//    private var imageName = BehaviorRelay<String?>(value: nil)
    private var imageData: Data? = nil
    private var imageName: String? = nil

    private var generationRequestID: Int? = nil
    private let disposeBag = DisposeBag()
    
    private let apiService: PixVerseAPIServiceProtocol
    private let storageService: UserDefaultsServiceProtocol
    private let cacheService: CacheServiceProtocol
    
    var selectedImage: Data?
    // TODO: remove view model logic from view, onNext only from here
    let loadTrigger = PublishRelay<Void>()
    let didTapInputField = PublishRelay<Void>()
    let didTapCreateButton = PublishRelay<Void>()
    let didCloseView = BehaviorSubject<Bool>(value: false)
    
    // Coordinator Input
    private let _shouldGenerateVideo = PublishRelay<GenerateBy>()
    var shouldGenerateVideo: Driver<GenerateBy> {
        _shouldGenerateVideo.asDriver(onErrorJustReturn: .prompt(prompt: ""))
    }
    
    private let _showLoading = PublishRelay<Void>()
    var showLoading: Driver<Void> {
        _showLoading.asDriver(onErrorJustReturn: ())
    }
    
    private let _generationFinished = PublishSubject<URL>()
    var generationFinished: Driver<URL> {
        _generationFinished.asDriver { _ in
            Driver.empty()
        }
    }
    
//    private let _generateVideo = PublishRelay<(Data, String)>()
    
    lazy var objectLoadedDriver: Driver<UseEffectModel?> = {
        return loadTrigger.map { self.getTemplate() }
            .asDriver(onErrorJustReturn: nil)
    }()
    
    init(effectID: Int, apiService: PixVerseAPIServiceProtocol, storageSevice: UserDefaultsServiceProtocol, cacheService: CacheServiceProtocol) {
        self.effectID = String(effectID)
        self.apiService = apiService
        self.storageService = storageSevice
        self.cacheService = cacheService
        
        bind()
    }
    
    // TODO: move checking timer logic to other layer
    func bind() {
        didTapCreateButton
//            .bind(to: _shouldGenerateVideo)
            .subscribe(onNext: {
                guard let imageData = self.imageData, let imageName = self.imageName else { return }
                self._shouldGenerateVideo.accept(.imageTemplate(imageData: imageData, imageName: imageName, templateID: self.effectID))
            })
            .disposed(by: disposeBag)
        
        // remove
//        didTapCreateButton
//            .asObservable()
//            .do(onNext: { _ in
//                self._showLoading.accept(())
//            })
//            .flatMapLatest { _ -> Observable<GenerationRequest> in
//                guard let imageData = self.imageData,
//                      let imageName = self.imageName else {
//                    print("No image data or name")
//                    return Observable.empty()
//                }
//                return self.apiService.generateFromTemplate(templateID: self.effectID, imageData: imageData, imageName: imageName)
//                    .asObservable()
//            }
//            .flatMapLatest { generationRequest -> Observable<(String, GeneratedVideo)> in
//                self.storageService.saveRequest(generationRequest)
//                self.generationRequestID = generationRequest.video_id
//                return self.apiService.observeVideoGenerationStatus(videoID: String(generationRequest.video_id))
////                return Observable<Int>.interval(.seconds(5), scheduler: ConcurrentDispatchQueueScheduler(qos: .background))
////                    .flatMapLatest { _ -> Observable<GeneratedVideo> in
////                        self.apiService.checkPendingRequest(requestID: String(generationRequest.video_id))
////                    }
////                    .share()
//            }
//            .filter { _, generatedVideo in
//                generatedVideo.status == "success" || generatedVideo.status == "error"
//            }
//            .take(1)
//            .subscribe(onNext: { videoID, generatedVideo in
//                guard let stringURL = generatedVideo.video_url,
//                      let url = URL(string: stringURL) else { return }
////                self._generationFinished.onNext(url)
//                self.storageService.saveGeneratedVideo(generatedVideo)
//                if let id = Int(videoID) {
//                    self.storageService.removeRequest(videoID: id)
//                }
//            }, onError: { error in
//                print(error)
//            })
//            .disposed(by: self.disposeBag)
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
        // TODO: show error when size of image > 1024 KB
        self.imageData = image.jpegData(compressionQuality: 0.5)
        print("размер файла: \(imageData?.count ?? 0)")
    }
}


