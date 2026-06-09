//
//  RatingDistribution.swift
//  Idoolk
//
//  Created by wang k on 2025/4/20.
//

import UIKit

class RatingDistribution: NSObject {
    
    static func generateRatingDistribution(voteCount: Int, rating: Double) -> [Int: Int] {
        // 初始化分布字典，1星固定为0
        var distribution: [Int: Int] = [5: 0, 4: 0, 3: 0, 2: 0, 1: 0]
        
        // 确保评分在合理范围内
        let clampedRating = min(5.0, max(1.0, rating))
        
        // 计算确定性分布，不使用随机数
        // 根据评分调整各星级的比例
        let fiveStarPercent = 40 + Int((clampedRating - 3.0) * 20)  // 范围约20%-60%
        let fourStarPercent = 35  // 固定35%
        let threeStarPercent = 20 - Int((clampedRating - 3.0) * 10)  // 范围约10%-30%
        let twoStarPercent = 5 - Int((clampedRating - 3.0) * 2)  // 范围约1%-7%
        
        // 确保所有百分比都为正数
        let safeThreeStarPercent = max(5, threeStarPercent)
        let safeTwoStarPercent = max(1, twoStarPercent)
        
        // 计算总百分比，然后重新归一化确保总和为100%
        let totalPercent = fiveStarPercent + fourStarPercent + safeThreeStarPercent + safeTwoStarPercent
        
        // 按比例计算各评分人数
        distribution[5] = (fiveStarPercent * voteCount) / totalPercent
        distribution[4] = (fourStarPercent * voteCount) / totalPercent
        distribution[3] = (safeThreeStarPercent * voteCount) / totalPercent
        distribution[2] = (safeTwoStarPercent * voteCount) / totalPercent
        distribution[1] = 0  // 1星固定为0
        
        // 处理舍入误差，确保总数等于voteCount
        let totalAllocated = distribution.values.reduce(0, +)
        let diff = voteCount - totalAllocated
        
        // 将差值加到5星上
        distribution[5]! += diff
        
        // 最后检查确保没有负数
        for key in distribution.keys {
            distribution[key] = max(0, distribution[key]!)
        }
        
        return distribution
    }
    
    // 用于生成确定性随机数的生成器
    struct SeededRandomNumberGenerator: RandomNumberGenerator {
        private var seed: UInt64
        
        init(seed: UInt64) {
            self.seed = seed
        }
        
        mutating func next() -> UInt64 {
            seed = 6364136223846793005 &* seed &+ 1
            return seed
        }
    }
    
}
