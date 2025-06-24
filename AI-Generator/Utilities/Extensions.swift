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
    func rxLoadImage() -> Single<UIImage> {
        return Single.create { single in
            guard self.canLoadObject(ofClass: UIImage.self) else {
                single(.failure(NSError(domain: "RxLoadImageError: cannot load image", code: -1)))
                return Disposables.create {}
            }
            
            self.loadObject(ofClass: UIImage.self) { image, error in
                if let error = error {
                    single(.failure(error))
                    return
                }
                
                guard let image = image as? UIImage else {
                    single(.failure(NSError(domain: "RxLoadImageError: failed while loading image", code: -1)))
                    return
                }
                
                single(.success(image))
            }
            
            return Disposables.create {}
        }
    }
    
    func rxLoadImageName() -> Single<String> {
        return Single.create { single in
            guard self.hasItemConformingToTypeIdentifier(UTType.image.identifier) else {
                single(.failure(NSError(domain: "RxLoadImageNameError: has not item conforming to UIImage identifier", code: -1)))
                return Disposables.create()
            }
            
            self.loadFileRepresentation(forTypeIdentifier: UTType.image.identifier) { url, error in
                if let error = error {
                    single(.failure(error))
                    return
                }
                
                guard let url = url else {
                    single(.failure(NSError(domain: "RxLoadImageNameError", code: -1)))
                    return
                }
                
                let fileName = url.lastPathComponent
                single(.success(fileName))
            }
            
            return Disposables.create()
        }
    }
}
