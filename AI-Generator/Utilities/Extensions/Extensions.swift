//
//  Extensions.swift
//  AI-Generator
//
//  Created by катенька on 17.06.2025.
//

import UIKit
import PhotosUI
import RxSwift
import UniformTypeIdentifiers

extension UIColor {
    static var appBlue: UIColor {
        return UIColor(red: 17/255, green: 52/255, blue: 1, alpha: 1)
    }
    
    static var appDarkGrey: UIColor {
        return UIColor(red: 44/255, green: 44/255, blue: 44/255, alpha: 1)
    }
    
    static var appGrey: UIColor {
        return UIColor(red: 100/255, green: 100/255, blue: 100/255, alpha: 1)
    }
    
    static var appBlack60: UIColor {
        return UIColor(red: 34/255, green: 34/255, blue: 34/255, alpha: 1)
    }
    
    static var appDark: UIColor {
        return UIColor(red: 23/255, green: 23/255, blue: 23/255, alpha: 1)
    }
    
    static var appPaleGrey30: UIColor {
        return UIColor(red: 237/255, green: 237/255, blue: 237/255, alpha: 0.7)
    }
}

extension UINavigationController {
    func configureNavigationBar() {
        let navBarAppearance = UINavigationBarAppearance()
        navBarAppearance.configureWithOpaqueBackground()
        navBarAppearance.backgroundColor = .black
        navBarAppearance.titleTextAttributes = [.foregroundColor: UIColor.white]
        navBarAppearance.largeTitleTextAttributes = [.foregroundColor: UIColor.white]
        self.navigationBar.standardAppearance = navBarAppearance
        self.navigationBar.prefersLargeTitles = true
        self.navigationBar.tintColor = .white
    }
}

extension NSItemProvider {
    func rxLoadMediaFile<T: NSItemProviderReading>(ofType: T.Type) -> Single<T> {
        return Single.create { single in
            guard self.canLoadObject(ofClass: T.self) else {
                single(.failure(NSError(domain: "RxLoadMediaFileError: cannot load file", code: -1)))
                return Disposables.create {}
            }
            
            self.loadObject(ofClass: T.self) { image, error in
                if let error = error {
                    single(.failure(error))
                    return
                }
                
                guard let image = image as? T else {
                    single(.failure(NSError(domain: "RxLoadMediaFileError: failed while loading file", code: -1)))
                    return
                }
                
                single(.success(image))
            }
            
            return Disposables.create {}
        }
    }
    
    func rxLoadMediaFilePath(for typeIdentifiers: [String]) -> Single<URL> {
        return Single.create { single in
            guard let identifier = typeIdentifiers.first(where: { self.hasItemConformingToTypeIdentifier($0) }) else {
                single(.failure(NSError(domain: "RxLoadImageNameError: item doesn't conforming to passed type identifiers", code: -1)))
                return Disposables.create()
            }
            
            self.loadFileRepresentation(forTypeIdentifier: identifier) { url, error in
                if let error = error {
                    single(.failure(error))
                    return
                }
                
                guard let url = url else {
                    single(.failure(NSError(domain: "RxLoadMediaFileNameError", code: -1)))
                    return
                }
                
                single(.success(url))
            }
            
            return Disposables.create()
        }
    }
}
