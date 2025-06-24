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
    var clearInputDataDriver: Driver<Void> { get }
}

protocol UsePromptViewModelOutputs {
    var didTappedOpenPaywall: PublishRelay<Void> { get }
//    var didTapInputField: PublishRelay<Void> { get }
    var didTapCreate: PublishRelay<Void> { get }
    var promptToGenerate: PublishRelay<String?> { get }
    func setImageName(name: String)
    func setImageData(image: UIImage)
}

protocol UsePromptViewModelToView {
    var input: UsePromptViewModelInputs { get }
    var output: UsePromptViewModelOutputs { get }
}

protocol UsePromptViewModelToCoordinator {
    var shouldOpenPaywall: Observable<Void> { get }
    var shouldGenerateVideo: Driver<GenerateBy> { get }
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
    
    // ViewController inputs
    private let _clearInputData = PublishRelay<Void>()
    var clearInputDataDriver: Driver<Void> {
        _clearInputData.asDriver(onErrorJustReturn: ())
    }
    
    // ViewController outputs
    var didTappedOpenPaywall = PublishRelay<Void>()
//    var didTapInputField = PublishRelay<Void>()
    var didTapCreate = PublishRelay<Void>()
    var promptToGenerate = PublishRelay<String?>()
    
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
                
                self._clearInputData.accept(())
            })
            .disposed(by: disposeBag)
    }
    
    func setImageName(name: String) {
        self.imageName = name
    }
    
    func setImageData(image: UIImage) {
        self.imageData = image.jpegData(compressionQuality: 0.5)
        print("размер файла: \(imageData?.count ?? 0)")
    }
}
