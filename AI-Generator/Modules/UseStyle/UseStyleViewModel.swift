//
//  UseStyleViewModel.swift
//  AI-Generator
//
//  Created by катенька on 25.06.2025.
//

import Foundation
import RxSwift
import RxCocoa

protocol UseStylesViewModelInputs {
    var modelToDisplay: Driver<UseEffectModel> { get }
}

protocol UseStylesViewModelOutputs {
    var loadData: PublishRelay<Void> { get }
    var didTapInputField: PublishRelay<Void> { get }
    var didTapCreateButton: PublishRelay<Void> { get }
    func setVideoData(with url: URL)
}

protocol UseStylesViewModelToView {
    var input: UseStylesViewModelInputs { get }
    var output: UseStylesViewModelOutputs { get }
}

protocol UseStylesViewModelToCoordinator {
    var shouldGenerateVideo: Driver<GenerateBy> { get }
}

class UseStyleViewModel: ViewModelConfigurable, UseStylesViewModelInputs, UseStylesViewModelOutputs, UseStylesViewModelToView, UseStylesViewModelToCoordinator {
    private let apiService: PixVerseAPIServiceProtocol
    private let storageService: UserDefaultsServiceProtocol
    private let style: Style
    private var videoData: Data? = nil
    private var videoName: String? = nil
    private let disposeBag = DisposeBag()
    
    var input: UseStylesViewModelInputs { self }
    var output: UseStylesViewModelOutputs { self }
    
    // ViewController Inputs
    private let _modelToDisplay = PublishRelay<UseEffectModel>()
    var modelToDisplay: Driver<UseEffectModel> {
        _modelToDisplay.asDriver(onErrorJustReturn: UseEffectModel.empty())
    }
    
    // ViewController Outputs
    var loadData = PublishRelay<Void>()
    var didTapInputField = PublishRelay<Void>()
    var didTapCreateButton = PublishRelay<Void>()
    
    // Coordinator Inputs
    private let _shouldGenerateVideo = PublishRelay<GenerateBy>()
    var shouldGenerateVideo: Driver<GenerateBy> {
        _shouldGenerateVideo.asDriver(onErrorJustReturn: .prompt(prompt: ""))
    }
    
    init(apiService: PixVerseAPIServiceProtocol, storageService: UserDefaultsServiceProtocol, style: Style) {
        self.apiService = apiService
        self.storageService = storageService
        self.style = style
        
        setupBindings()
    }
    
    func setupBindings() {
        loadData
            .subscribe(onNext: {
                let objectToDisplay = UseEffectModel(title: self.style.name, templateId: self.style.template_id, videoURL: URL(string: self.style.preview_large))
                self._modelToDisplay.accept(objectToDisplay)
            })
            .disposed(by: disposeBag)
        
        didTapCreateButton
            .subscribe(onNext: {
                guard let videoData = self.videoData,
                      let videoName = self.videoName else { return }
                self._shouldGenerateVideo.accept(.videoStyle(videoData: videoData, videoName: videoName, templateID: String(self.style.template_id)))
            })
            .disposed(by: disposeBag)
    }
    
    func setVideoData(with url: URL) {
        self.videoName = url.lastPathComponent
        do {
            self.videoData = try Data(contentsOf: url)
        } catch {
            print("\(#file): \(error)")
        }
        print("размер файла: \(self.videoData?.count ?? 0)")
    }
}
