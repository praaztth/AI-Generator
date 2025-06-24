//
//  VideoGenerationViewModel.swift
//  AI-Generator
//
//  Created by катенька on 24.06.2025.
//

import Foundation

protocol VideoGenerationViewModelInputs {
    
}

protocol VideoGenerationViewModelOutputs {
    
}

protocol VideoGenerationViewModelToView {
    var input: VideoGenerationViewModelInputs { get }
    var output: VideoGenerationViewModelOutputs { get }
}

class VideoGenerationViewModel: ViewModelConfigurable, VideoGenerationViewModelInputs, VideoGenerationViewModelOutputs, VideoGenerationViewModelToView {
    var input: VideoGenerationViewModelInputs { self }
    var output: VideoGenerationViewModelOutputs { self }
    
    func setupBindings() {
        
    }
}
