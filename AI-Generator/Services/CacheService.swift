//
//  CacheService.swift
//  AI-Generator
//
//  Created by катенька on 21.06.2025.
//

import Foundation

protocol CacheServiceProtocol {
    func setObject(_ object: AnyObject, forKey key: String)
    func getObject(forKey key: String) -> AnyObject?
}

final class CacheService: CacheServiceProtocol {
    static let shared = CacheService()
    private let cache = NSCache<NSString, AnyObject>()
    
    func setObject(_ object: AnyObject, forKey key: String) {
        cache.setObject(object, forKey: NSString(string: key))
    }
    
    func getObject(forKey key: String) -> AnyObject? {
        return cache.object(forKey: NSString(string: key))
    }
    
}
