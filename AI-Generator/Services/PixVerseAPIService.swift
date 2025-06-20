//
//  PixVerseAPIService.swift
//  AI-Generator
//
//  Created by катенька on 20.06.2025.
//

import RxSwift

struct TemplateResponse: Codable {
    let app_id: String
    let templates: [Template]
    let styles: [Style]
    let id: Int
}

struct Template: Codable {
    let prompt: String
    let name: String
    let category: String
    let is_active: Bool
    let preview_small: String
    let preview_large: String
    let id: Int
    let template_id: Int
}

struct Style: Codable {
    let prompt: String
    let name: String
    let is_active: Bool
    let preview_small: String
    let preview_large: String
    let id: Int
    let template_id: Int
}

protocol PixVerseAPIServiceProtocol {
    func fetchTemplates() -> Single<TemplateResponse>
}

enum PixVerseAPIError: Error {
    case requestFailed(Error)
    case decodingError(Error)
    case notFound
}

class PixVerseAPIService: PixVerseAPIServiceProtocol {
    func fetchTemplates() -> Single<TemplateResponse> {
        let url = URL(string: Constants.baseURL + "/api/v1/get_templates/\(Constants.appID)")!
        
        return Single<TemplateResponse>.create { single in
            let task = URLSession.shared.dataTask(with: url) { data, response, error in
                if let error = error {
                    single(.failure(PixVerseAPIError.requestFailed(error)))
                    return
                }
                
                guard let data = data else {
                    single(.failure(PixVerseAPIError.notFound))
                    return
                }
                
                do {
                    let templateResponse = try JSONDecoder().decode(TemplateResponse.self, from: data)
                    single(.success(templateResponse))
                } catch {
                    single(.failure(PixVerseAPIError.decodingError(error)))
                }
            }
            task.resume()
            
            return Disposables.create {
                task.cancel()
            }
        }
    }
}
