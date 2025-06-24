//
//  UseEffectViewController.swift
//  AI-Generator
//
//  Created by катенька on 20.06.2025.
//

import UIKit
import GSPlayer
import RxSwift
import RxCocoa
import GSPlayer
import PhotosUI

class UseEffectViewController: UIViewController {
    private let customView = UseEffectView()
    private let viewModel: UseEffectViewModelProtocol
    private let disposeBag = DisposeBag()
    
    init(viewModel: UseEffectViewModelProtocol) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        self.view = customView
    }
    
    override func viewDidLoad() {
        bindViewModel()
        bindView()
        loadData()
    }
    
    func loadData() {
        viewModel.loadTrigger.accept(())
    }
    
    func bindView() {
        customView.setVideoStateDidChagedCallback { [weak self] state in
            switch state {
            case .loading:
                self?.customView.startActivityIndicator()
            case .playing:
                self?.customView.stopActivityIndicator()
            case .error:
                self?.customView.showError()
            default:
                break
            }
        }
        
        customView.bindInputButton(to: viewModel.didTapInputField)
        customView.bindCreateButton(to: viewModel.didTapCreateButton)
    }
    
    func bindViewModel() {
        viewModel.objectLoadedDriver
            .drive(onNext: { [weak self] object in
                guard let object = object else { return }
                self?.customView.configure(withObject: object)
            })
            .disposed(by: disposeBag)
        
        viewModel.didTapInputField
            .subscribe(onNext: { [weak self] _ in
                self?.displayVideoPicker()
            })
            .disposed(by: disposeBag)
    }
    
    func displayVideoPicker() {
        var configuration = PHPickerConfiguration(photoLibrary: .shared())
        let filter = PHPickerFilter.images
        configuration.filter = filter
        configuration.preferredAssetRepresentationMode = .compatible
        configuration.selectionLimit = 1
        
        let picker = PHPickerViewController(configuration: configuration)
        picker.delegate = self
        present(picker, animated: true)
    }
}

extension UseEffectViewController: PHPickerViewControllerDelegate {
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        picker.dismiss(animated: true)
        
        guard let result = results.first else { return }
        
        ImagePickerHelper.handlePickedResults(result: result)
            .observe(on: MainScheduler.instance)
            .subscribe { [weak self] image, imageName in
                self?.viewModel.setImageData(image: image)
                self?.viewModel.setImageName(name: imageName)
                self?.customView.setSelectedImage(image: image)
                
            } onFailure: { error in
                print(error)
            }
            .disposed(by: disposeBag)

        
        // TODO: move to viewModel
//        guard let itemProvider = results.first?.itemProvider,
//              itemProvider.canLoadObject(ofClass: UIImage.self) else {
//            return
//        }
//        
//        if itemProvider.hasItemConformingToTypeIdentifier(UTType.image.identifier) {
//            _ = itemProvider.loadFileRepresentation(for: .image) { [weak self] url, openInPlace, error in
//                guard error == nil, let url = url else {
//                    print("Ошибка загрузки: \(error?.localizedDescription ?? "Неизвестная ошибка")")
//                    return
//                }
//                
//                let fileName = url.lastPathComponent
//                print("Имя файла: \(fileName)")
//                DispatchQueue.main.async {
//                    self?.viewModel.setImageName(name: fileName)
//                }
//            }
//        }
//        
//        itemProvider.loadObject(ofClass: UIImage.self) { [weak self] image, error in
//            guard let image = image as? UIImage,
//                  error == nil else {
//                return
//            }
//            
//            DispatchQueue.main.async {
//                self?.viewModel.setImageData(image: image)
//                self?.customView.setSelectedImage(image: image)
//            }
//        }
    }
}
