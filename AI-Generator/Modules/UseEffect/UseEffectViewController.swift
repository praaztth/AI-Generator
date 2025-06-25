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
        configureNavBar()
        customView.setUIEnabled(true)
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
    
    func configureNavBar() {
        let imageBarButton = UIImage(systemName: "sparkles")
        let barButton = BarButton(title: "PRO", backgroundColor: .appBlue, image: imageBarButton)
        barButton.addTarget(self, action: #selector(openPaywallButtonTapped), for: .touchUpInside)
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: barButton)
    }
    
    // TODO: reuse code
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
    
    @objc func openPaywallButtonTapped() {
        viewModel.didTapOpenPaywall.accept(())
    }
}

// TODO: move to view model
extension UseEffectViewController: PHPickerViewControllerDelegate {
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        picker.dismiss(animated: true)
        
        guard let result = results.first else { return }
        
        GalleryPickerHelper.handlePickedResults(ofType: UIImage.self, typeIdentifiers: [UTType.image.identifier], result: result)
            .observe(on: MainScheduler.instance)
            .subscribe { [weak self] image, url in
                self?.viewModel.setImageData(image: image)
                let imageName = url.lastPathComponent
                self?.viewModel.setImageName(name: imageName)
                DispatchQueue.main.async {
                    self?.customView.setSelectedImage(image: image)
                }
                
            } onFailure: { error in
                print(error)
            }
            .disposed(by: disposeBag)
    }
}
