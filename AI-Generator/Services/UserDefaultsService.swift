//
//  UserDefaultsService.swift
//  AI-Generator
//
//  Created by катенька on 18.06.2025.
//

import Foundation

protocol UserDefaultsServiceProtocol {
    var hasCompletedOnboarding: Bool { get set }
    func saveRequest(_ request: GenerationRequest)
    func getRequest(videoID: Int) -> GenerationRequest?
    func getGeneratedVideo(url: String) -> GeneratedVideo?
    func getAllRequests() -> [GenerationRequest]
    func removeRequest(videoID: Int)
    func saveGeneratedVideo(_ generatedVideo: GeneratedVideo)
    func removeGeneratedVideo(url: String)
}

final class UserDefaultsService: UserDefaultsServiceProtocol {
    private let hasCompletedOnboardingKey = "hasCompletedOnboarding"
    private let generationRequests = "generationRequests"
    private let generatedVideos = "generatedVideos"
    private let userDefaults = UserDefaults.standard
    
    var hasCompletedOnboarding: Bool {
        get { userDefaults.bool(forKey: hasCompletedOnboardingKey) }
        set { userDefaults.set(newValue, forKey: hasCompletedOnboardingKey) }
    }
    
    func saveRequest(_ request: GenerationRequest) {
        var requests = getAllObjects(ofType: GenerationRequest.self, for: generationRequests)
        requests.append(request)
        saveAllObjects(requests, for: generationRequests)
        print("request saved")
    }
    
    func getRequest(videoID: Int) -> GenerationRequest? {
        let requests = getAllRequests()
        let request = requests.first { $0.video_id == videoID }
        return request
    }
    
    func getGeneratedVideo(url: String) -> GeneratedVideo? {
        let generatedVideos = getAllObjects(ofType: GeneratedVideo.self, for: generatedVideos)
        let generatedVideo = generatedVideos.first { $0.video_url == url }
        return generatedVideo
    }
    
    func getAllRequests() -> [GenerationRequest] {
        getAllObjects(ofType: GenerationRequest.self, for: generationRequests)
    }
    
    func removeRequest(videoID: Int) {
        let key = generationRequests
        var requests = getAllObjects(ofType: GenerationRequest.self, for: key)
        if let index = requests.firstIndex(where: { $0.video_id == videoID }) {
            requests.remove(at: index)
            print("removed request with video_id: \(videoID)")
        }
        saveAllObjects(requests, for: key)
    }
    
    func saveGeneratedVideo(_ generatedVideo: GeneratedVideo) {
        let key = generatedVideos
        var videos = getAllObjects(ofType: GeneratedVideo.self, for: key)
        videos.append(generatedVideo)
        saveAllObjects(videos, for: key)
    }
    
    func removeGeneratedVideo(url: String) {
        let key = generatedVideos
        var videos = getAllObjects(ofType: GeneratedVideo.self, for: key)
        if let index = videos.firstIndex(where: { $0.video_url == url }) {
            videos.remove(at: index)
            print("removed video with url: \(url)")
        }
    }
    
    func getAllObjects<T: Decodable>(ofType type: T.Type, for key: String) -> [T] {
        guard let data = userDefaults.data(forKey: key) else { return [] }
        let objects = try? JSONDecoder().decode([T].self, from: data)
        return objects ?? []
    }
    
    func saveAllObjects<T: Encodable>(_ objects: [T], for key: String) {
        let data = try? JSONEncoder().encode(objects)
        userDefaults.set(data, forKey: key)
    }
}
