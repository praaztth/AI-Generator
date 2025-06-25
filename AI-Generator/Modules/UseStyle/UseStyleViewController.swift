//
//  UseStyleViewController.swift
//  AI-Generator
//
//  Created by катенька on 25.06.2025.
//

import UIKit
import GSPlayer
import RxSwift
import RxCocoa
import PhotosUI

class UseStyleViewController: UIViewController {
    private let customView = UseEffectView()
    private let viewModel: UseStylesViewModelToView
    private let disposeBag = DisposeBag()
    
    init(viewModel: UseStylesViewModelToView) {
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
        configureNavBar()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        viewModel.output.loadData.accept(())
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
        
        customView.bindInputButton(to: viewModel.output.didTapInputField)
        customView.bindCreateButton(to: viewModel.output.didTapCreateButton)
    }
    
    func bindViewModel() {
        viewModel.input.modelToDisplay
            .drive(onNext: { [weak self] object in
                self?.customView.configure(withObject: object)
            })
            .disposed(by: disposeBag)
        
        viewModel.output.didTapInputField
            .subscribe(onNext: { [weak self] _ in
                self?.displayVideoPicker()
            })
            .disposed(by: disposeBag)
        
        viewModel.input.proAccessAvailableDriver
            .drive(onNext: { [weak self] isAvailable in
                self?.setUIEnabled(isAvailable)
            })
            .disposed(by: disposeBag)
    }
    
    func configureNavBar() {
        let imageBarButton = UIImage(systemName: "sparkles")
        let barButton = BarButton(title: "PRO", backgroundColor: .appBlue, image: imageBarButton)
        barButton.addTarget(self, action: #selector(openPaywallButtonTapped), for: .touchUpInside)
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: barButton)
    }
    
    func setUIEnabled(_ isEnabled: Bool) {
        customView.setUIEnabled(isEnabled)
    }
    
    // TODO: reuse code
    func displayVideoPicker() {
        var configuration = PHPickerConfiguration(photoLibrary: .shared())
        let filter = PHPickerFilter.videos
        configuration.filter = filter
        configuration.preferredAssetRepresentationMode = .compatible
        configuration.selectionLimit = 1
        
        let picker = PHPickerViewController(configuration: configuration)
        picker.delegate = self
        present(picker, animated: true)
    }
    
    @objc func openPaywallButtonTapped() {
        viewModel.output.didTapOpenPaywall.accept(())
    }
}

// TODO: move to view model
extension UseStyleViewController: PHPickerViewControllerDelegate {
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        picker.dismiss(animated: true)
        
        guard let result = results.first else { return }
        let itemProvider = result.itemProvider
        
        let videoTypes: [UTType] = [
            .movie,
            .video,
            .mpeg4Movie,
            .avi,
            .quickTimeMovie,
            .mpeg,
            .mpeg2Video
        ]
        
        let videoTypeIdentifiers = videoTypes.map { $0.identifier }
        
        itemProvider.rxLoadMediaFilePath(for: videoTypeIdentifiers)
            .subscribe(onSuccess: { [weak self] url in
                // TODO: generate preview
                self?.viewModel.output.setVideoData(with: url)
                DispatchQueue.main.async {
                    self?.customView.setSelectedImage(image: UIImage())
                }
            }, onFailure: { error in
                print(error)
            })
            .disposed(by: disposeBag)
    }
}

