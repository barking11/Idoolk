//
//  CacheManager.swift
//  Idoolk
//
//  Created by wang k on 2025/4/23.
//

import UIKit
import Kingfisher

class CacheManager {
    
    static let shared = CacheManager()
    
    private init() {}
    
    /// 获取Kingfisher缓存大小（MB）
    func getCacheSize(completion: @escaping (Double) -> Void) {
        // 获取磁盘缓存大小
        KingfisherManager.shared.cache.calculateDiskStorageSize { result in
            switch result {
            case .success(let size):
                // 将字节转换为MB
                let sizeInMB = Double(size) / 1024.0 / 1024.0
                completion(sizeInMB)
            case .failure(let error):
                print("获取缓存大小失败: \(error.localizedDescription)")
                completion(0)
            }
        }
    }
    
    /// 清除所有缓存
    func clearCache(completion: @escaping (Bool) -> Void) {
        // 清除内存缓存
        KingfisherManager.shared.cache.clearMemoryCache()
        
        // 清除磁盘缓存
        KingfisherManager.shared.cache.clearDiskCache {
            completion(true)
        }
    }
    
    /// 清除过期的缓存
    func cleanExpiredCache(completion: @escaping (Bool) -> Void) {
        KingfisherManager.shared.cache.cleanExpiredDiskCache {
            completion(true)
        }
    }
    
}
