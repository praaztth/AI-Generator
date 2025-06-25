//
//  GenerationFlowHelper.swift
//  AI-Generator
//
//  Created by катенька on 24.06.2025.
//

import RxSwift

final class GenerationFlowHelper {
    static func createGenerationFlow(apiService: PixVerseAPIServiceProtocol, storageService: UserDefaultsServiceProtocol, generateClosure: @escaping () -> Observable<GenerationRequest>
    ) -> Observable<String> {
        let videoStatusObservable = generateClosure()
            .flatMapLatest { generationRequest -> Observable<(String, GeneratedVideo)> in
                print(generationRequest)
                storageService.saveRequest(generationRequest)
                return apiService.observeVideoGenerationStatus(videoID: String(generationRequest.video_id))
            }
        
        let filteredResult = videoStatusObservable
            .filter { videoID, generatedVideo in
                generatedVideo.status == "success" || generatedVideo.status == "error"
            }
            .take(1)
            .do(onNext: { videoID, generatedVideo in
                if let id = Int(videoID) {
                    storageService.removeRequest(videoID: id)
                }
                storageService.saveGeneratedVideo(generatedVideo)
            })
            .map { _, generatedVideo in
                generatedVideo.video_url ?? ""
            }
                
        return filteredResult
    }
}
