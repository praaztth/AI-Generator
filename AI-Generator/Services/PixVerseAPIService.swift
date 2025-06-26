//
//  PixVerseAPIService.swift
//  AI-Generator
//
//  Created by катенька on 20.06.2025.
//

import RxSwift

protocol PixVerseAPIServiceProtocol {
    func fetchTemplates() -> Single<TemplateResponse>
    func generateFromTemplate(templateID: String, imageData: Data, imageName: String) -> Single<GenerationRequest>
    func generateFromPrompt(prompt: String) -> Single<GenerationRequest>
    func generateFromPromptAndImage(prompt: String, imageData: Data, imageName: String) -> Single<GenerationRequest>
    func generateFromStyle(templateID: String, videoData: Data, videoName: String) -> Single<GenerationRequest>
    func checkPendingRequest(requestID: String) -> Observable<GeneratedVideo>
    func observeVideoGenerationStatus(videoID: String) -> Observable<(String, GeneratedVideo)>
}

enum PixVerseAPIError: LocalizedError {
    case requestFailed(Error)
    case decodingError(String)
    case notFound
    
    var errorDescription: String? {
        switch self {
        case .requestFailed(let error):
            NSLocalizedString(error.localizedDescription, comment: "")
        case .decodingError(let string):
            NSLocalizedString(string, comment: "")
        case .notFound:
            NSLocalizedString("Source wasn't found", comment: "")
        }
    }
}

enum PixVerseAPIGenerationStatus {
    case success
    case processing
    case failed
}

class PixVerseAPIService: PixVerseAPIServiceProtocol {
    func fetchTemplates() -> Single<TemplateResponse> {
        var url = URL(string: Constants.baseURL)!
        url = url.appending(path: "api")
            .appending(path: "v1")
            .appending(path: "get_templates")
            .appending(path: Constants.appID)
        
        return get(url: url, body: nil, contentType: nil)
    }
    
    func generateFromTemplate(templateID: String, imageData: Data, imageName: String) -> Single<GenerationRequest> {
        var url = URL(string: Constants.baseURL)!
        url = url.appending(path: "api")
            .appending(path: "v1")
            .appending(path: "template2video")
            .appending(queryItems: [
                URLQueryItem(name: "userId", value: "test"),
                URLQueryItem(name: "appId", value: Constants.appID),
                URLQueryItem(name: "templateId", value: templateID)
            ])
        
        let boundary = "Boundary-\(UUID().uuidString)"
        let typeName = "image"
        let fileTypeName = "image/png"
        let body = createMultipartBody(mediaData: imageData, mediaName: imageName, typeName: typeName, contentType: fileTypeName, boundary: boundary)
        let contentType = "multipart/form-data; boundary=\(boundary)"
        
        return post(url: url, body: body, contentType: contentType)
    }
    
    func generateFromPrompt(prompt: String) -> Single<GenerationRequest> {
        var url = URL(string: Constants.baseURL)!
        url = url.appending(path: "api")
            .appending(path: "v1")
            .appending(path: "text2video")
            .appending(queryItems: [
                URLQueryItem(name: "userId", value: "test"),
                URLQueryItem(name: "appId", value: Constants.appID),
                URLQueryItem(name: "promptText", value: prompt)
            ])
        
        return post(url: url, body: nil, contentType: nil)
    }
    
    func generateFromPromptAndImage(prompt: String, imageData: Data, imageName: String) -> Single<GenerationRequest> {
        var url = URL(string: Constants.baseURL)!
        url = url.appending(path: "api")
            .appending(path: "v1")
            .appending(path: "image2video")
            .appending(queryItems: [
                URLQueryItem(name: "userId", value: "test"),
                URLQueryItem(name: "appId", value: Constants.appID),
                URLQueryItem(name: "promptText", value: prompt)
            ])
        
        let boundary = "Boundary-\(UUID().uuidString)"
        let typeName = "image"
        let fileTypeName = "image/png"
        let body = createMultipartBody(mediaData: imageData, mediaName: imageName, typeName: typeName, contentType: fileTypeName, boundary: boundary)
        let contentType = "multipart/form-data; boundary=\(boundary)"
        
        return post(url: url, body: body, contentType: contentType)
    }
    
    func generateFromStyle(templateID: String, videoData: Data, videoName: String) -> Single<GenerationRequest> {
        var url = URL(string: Constants.baseURL)!
        url = url.appending(path: "api")
            .appending(path: "v1")
            .appending(path: "video2video")
            .appending(queryItems: [
                URLQueryItem(name: "userId", value: "test"),
                URLQueryItem(name: "appId", value: Constants.appID),
                URLQueryItem(name: "templateId", value: templateID)
            ])
        
        let boundary = "Boundary-\(UUID().uuidString)"
        let typeName = "video"
        let fileTypeName = "video/mp4"
        let body = createMultipartBody(mediaData: videoData, mediaName: videoName, typeName: typeName, contentType: fileTypeName, boundary: boundary)
        let contentType = "multipart/form-data; boundary=\(boundary)"
        
        return post(url: url, body: body, contentType: contentType)
    }
    
    func checkPendingRequest(requestID: String) -> Observable<GeneratedVideo> {
        var url = URL(string: Constants.baseURL)!
        url = url.appending(path: "api")
            .appending(path: "v1")
            .appending(path: "status")
            .appending(queryItems: [URLQueryItem(name: "id", value: requestID)])
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        return Observable<GeneratedVideo>.create { observer in
            let task = self.createDataTask(request: request) { result in
                switch result {
                case .success(let data):
                    do {
                        let generatedVideo = try JSONDecoder().decode(GeneratedVideo.self, from: data)
                        observer.onNext(generatedVideo)
                    } catch {
                        if let responce = try? JSONSerialization.jsonObject(with: data) as? String {
                            observer.onError(PixVerseAPIError.decodingError(responce))
                        } else {
                            let responce = String(data: data, encoding: .utf8) ?? "Unknown error"
                            observer.onError(PixVerseAPIError.decodingError(responce))
                        }
                        
                    }
                case .failure(let error):
                    observer.onError(error)
                }
            }
            task.resume()
            
            return Disposables.create {
                task.cancel()
            }
        }
    }
    
    func observeVideoGenerationStatus(videoID: String) -> Observable<(String, GeneratedVideo)> {
        return Observable<Int>.interval(.seconds(5), scheduler: ConcurrentDispatchQueueScheduler(qos: .background))
            .flatMapLatest { _ -> Observable<(String, GeneratedVideo)> in
                self.checkPendingRequest(requestID: videoID)
                    .map { (videoID, $0) }
            }
            .share()
    }
    
    func createDataTask(request: URLRequest, completion: @escaping (Result<Data, PixVerseAPIError>) -> Void) -> URLSessionDataTask {
        return URLSession.shared.dataTask(with: request) { data, _, error in
            if let error = error {
                completion(.failure(.requestFailed(error)))
                return
            }
            
            guard let data = data else {
                completion(.failure(.notFound))
                return
            }
            
            completion(.success(data))
        }
    }
    
    func get<T: Decodable>(url: URL, body: Data?, contentType: String?) -> Single<T> {
        request(url: url, method: "GET", body: body, contentType: contentType)
    }
    
    func post<T: Decodable>(url: URL, body: Data?, contentType: String?) -> Single<T> {
        request(url: url, method: "POST", body: body, contentType: contentType)
    }
    
    func request<T: Decodable>(url: URL, method: String, body: Data?, contentType: String?) -> Single<T> {
        var request = URLRequest(url: url)
        request.httpMethod = method
        request.setValue("application/json", forHTTPHeaderField: "accept")
        if let contentType = contentType {
            request.setValue(contentType, forHTTPHeaderField: "Content-Type")
        }
        request.httpBody = body
        
        return Single<T>.create { single in
            let task = self.createDataTask(request: request) { result in
                switch result {
                case .success(let data):
                    do {
                        let decoded = try JSONDecoder().decode(T.self, from: data)
                        single(.success(decoded))
                    } catch {
                        let jsonResponse = try? JSONSerialization.jsonObject(with: data) as? String
                        let utfResponse = String(data: data, encoding: .utf8)
                        
                        single(.failure(PixVerseAPIError.decodingError(jsonResponse ?? utfResponse ?? "Unknown decoding error")))
                    }
                case .failure(let error):
                    single(.failure(error))
                }
            }
            task.resume()
            
            return Disposables.create {
                task.cancel()
            }
        }
    }
    
    func createMultipartBody(mediaData: Data, mediaName: String, typeName: String, contentType: String, boundary: String) -> Data {
        var body = Data()
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"\(typeName)\"; filename=\"\(mediaName)\"\r\n".data(using: .utf8)!)
        body.append("Content-Type: \(contentType)\r\n\r\n".data(using: .utf8)!)
        body.append(mediaData)
        body.append("\r\n".data(using: .utf8)!)
        body.append("--\(boundary)--\r\n".data(using: .utf8)!)
        
        return body
    }
}
