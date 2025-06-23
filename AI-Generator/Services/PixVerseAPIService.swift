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
    func checkPendingRequest(requestID: String) -> Observable<GeneratedVideo>
}

enum PixVerseAPIError: Error {
    case requestFailed(Error)
    case decodingError(Error)
    case notFound
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
        
        return Single<TemplateResponse>.create { single in
            let task = URLSession.shared.dataTask(with: url) { data, response, error in
                if let error = error {
                    single(.failure(PixVerseAPIError.requestFailed(error)))
                    print(PixVerseAPIError.requestFailed(error))
                    return
                }
                
                guard let data = data else {
                    single(.failure(PixVerseAPIError.notFound))
                    print(PixVerseAPIError.notFound)
                    return
                }
                
                do {
                    let templateResponse = try JSONDecoder().decode(TemplateResponse.self, from: data)
                    single(.success(templateResponse))
                } catch {
                    single(.failure(PixVerseAPIError.decodingError(error)))
                    print(PixVerseAPIError.decodingError(error))
                }
            }
            task.resume()
            
            return Disposables.create {
                task.cancel()
            }
        }
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
        print(templateID)
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        let boundary = "Boundary-\(UUID().uuidString)"
        
        request.setValue("application/json", forHTTPHeaderField: "accept")
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        
        let body = createMultipartBody(imageData: imageData, imageName: imageName, boundary: boundary)
        request.httpBody = body
        
        return Single<GenerationRequest>.create { single in
            let task = self.createDataTask(request: request) { result in
                switch result {
                case .success(let data):
                    do {
                        let generationRequest = try JSONDecoder().decode(GenerationRequest.self, from: data)
                        single(.success(generationRequest))
                    } catch {
                        single(.failure(PixVerseAPIError.decodingError(error)))
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
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        //TODO: move single.create to reparated method
        return Single<GenerationRequest>.create { single in
            let task = self.createDataTask(request: request) { result in
                switch result {
                case .success(let data):
                    do {
                        let generationRequest = try JSONDecoder().decode(GenerationRequest.self, from: data)
                        single(.success(generationRequest))
                    } catch {
                        single(.failure(PixVerseAPIError.decodingError(error)))
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
    
    func generateFromImagePrompt(prompt: String, imageData: Data, imageName: String) -> Single<GenerationRequest> {
        var url = URL(string: Constants.baseURL)!
        url = url.appending(path: "api")
            .appending(path: "v1")
            .appending(path: "image2video")
            .appending(queryItems: [
                URLQueryItem(name: "userId", value: "test"),
                URLQueryItem(name: "appId", value: Constants.appID),
                URLQueryItem(name: "promptText", value: prompt)
            ])
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        let boundary = "Boundary-\(UUID().uuidString)"
        
        request.setValue("application/json", forHTTPHeaderField: "accept")
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        
        let body = createMultipartBody(imageData: imageData, imageName: imageName, boundary: boundary)
        request.httpBody = body
        
        return Single<GenerationRequest>.create { single in
            let task = self.createDataTask(request: request) { result in
                switch result {
                case .success(let data):
                    do {
                        let generationRequest = try JSONDecoder().decode(GenerationRequest.self, from: data)
                        single(.success(generationRequest))
                    } catch {
                        single(.failure(PixVerseAPIError.decodingError(error)))
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
    
    // TODO: one common method from this two
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
                        observer.onError(PixVerseAPIError.decodingError(error))
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
                        single(.failure(PixVerseAPIError.decodingError(error)))
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
    
    func createMultipartBody(imageData: Data, imageName: String, boundary: String) -> Data {
        var body = Data()
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"image\"; filename=\"\(imageName)\"\r\n".data(using: .utf8)!)
        body.append("Content-Type: image/png\r\n\r\n".data(using: .utf8)!)
        body.append(imageData)
        body.append("\r\n".data(using: .utf8)!)
        body.append("--\(boundary)--\r\n".data(using: .utf8)!)
        
        return body
    }
}
