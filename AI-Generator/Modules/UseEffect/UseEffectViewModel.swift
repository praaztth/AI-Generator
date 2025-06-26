//
//  UseEffectViewModel.swift
//  AI-Generator
//
//  Created by катенька on 20.06.2025.
//

import Foundation
import UIKit
import RxSwift
import RxCocoa

protocol UseEffectViewModelProtocol {
    var loadTrigger: PublishRelay<Void> { get }
    var didTapInputField: PublishRelay<Void> { get }
    var didTapCreateButton: PublishRelay<Void> { get }
    var didCloseView: BehaviorSubject<Bool> { get }
    var didTapOpenPaywall: PublishRelay<Void> { get }
    var objectLoadedDriver: Driver<UseEffectModel?> { get }
    
    var shouldGenerateVideo: Driver<GenerateBy> { get }
    var shouldShowAlert: Driver<String> { get }
    var shouldOpenPaywall: Observable<Void> { get }
    
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
    
    var selectedImage: Data?
    // TODO: remove view model logic from view, onNext only from here
    let loadTrigger = PublishRelay<Void>()
    let didTapInputField = PublishRelay<Void>()
    let didTapCreateButton = PublishRelay<Void>()
    let didCloseView = BehaviorSubject<Bool>(value: false)
    var didTapOpenPaywall = PublishRelay<Void>()
    
    // Coordinator Input
    private let _shouldGenerateVideo = PublishRelay<GenerateBy>()
    var shouldGenerateVideo: Driver<GenerateBy> {
        _shouldGenerateVideo.asDriver(onErrorJustReturn: .prompt(prompt: ""))
    }
    
    private let _shouldShowAlert = PublishRelay<String>()
    var shouldShowAlert: Driver<String> {
        _shouldShowAlert.asDriver(onErrorJustReturn: "")
    }
    
    private let _shouldOpenPaywall = PublishRelay<Void>()
    var shouldOpenPaywall: Observable<Void> {
        _shouldOpenPaywall.asObservable()
    }
    
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
    
    func bind() {
        didTapCreateButton
            .subscribe(onNext: {
                guard let imageData = self.imageData, let imageName = self.imageName else { return }
                let generationRequests = self.storageService.getAllRequests()
                guard generationRequests.count < 2 else {
                    self._shouldShowAlert.accept("You can only run up to 2 generations at the same time")
                    return
                }
                self._shouldGenerateVideo.accept(.imageTemplate(imageData: imageData, imageName: imageName, templateID: self.effectID))
            })
            .disposed(by: disposeBag)
        
        didTapOpenPaywall
            .bind(to: _shouldOpenPaywall)
            .disposed(by: disposeBag)
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


