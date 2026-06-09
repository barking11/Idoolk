import SwiftUI
import UIKit

/// UI尺寸辅助工具类
struct UIHelper {
    // MARK: - 屏幕尺寸
    /// 屏幕宽度
    static let screenWidth = UIScreen.main.bounds.width
    
    /// 屏幕高度
    static let screenHeight = UIScreen.main.bounds.height
    
    // MARK: - 安全区域
    /// 顶部安全区域高度（状态栏高度）
    static var topSafeAreaInset: CGFloat {
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let window = windowScene.windows.first {
            return window.safeAreaInsets.top
        }
        return 0
    }
    
    /// 底部安全区域高度（Home Indicator高度）
    static var bottomSafeAreaInset: CGFloat {
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let window = windowScene.windows.first {
            return window.safeAreaInsets.bottom
        }
        return 0
    }
    
    // MARK: - 导航栏和TabBar尺寸
    /// 导航栏高度（不包含状态栏）
    static let navigationBarHeight: CGFloat = 44.0
    
    /// 导航栏总高度（包含状态栏）
    static var navigationBarTotalHeight: CGFloat {
        return navigationBarHeight + topSafeAreaInset
    }
    
    /// TabBar高度（不包含底部安全区域）
    static let tabBarHeight: CGFloat = 49.0
    
    /// TabBar总高度（包含底部安全区域）
    static var tabBarTotalHeight: CGFloat {
        return tabBarHeight + bottomSafeAreaInset
    }
    
    // MARK: - 设备类型判断
    /// 是否为iPad
    static let isIPad = UIDevice.current.userInterfaceIdiom == .pad
    
    /// 是否为iPhone
    static let isIPhone = UIDevice.current.userInterfaceIdiom == .phone
    
    // MARK: - 常用布局尺寸
    /// 标准边距
    static let standardPadding: CGFloat = 16.0
    
    /// 小边距
    static let smallPadding: CGFloat = 8.0
    
    /// 大边距
    static let largePadding: CGFloat = 24.0
    
    /// 标准圆角
    static let standardCornerRadius: CGFloat = 12.0
    
    /// 小圆角
    static let smallCornerRadius: CGFloat = 8.0
    
    /// 大圆角
    static let largeCornerRadius: CGFloat = 16.0
    
    // MARK: - 辅助方法
    /// 根据不同设备等比例缩放尺寸
    static func adaptiveSize(_ size: CGFloat, baseWidth: CGFloat = 390.0) -> CGFloat {
        return (screenWidth / baseWidth) * size
    }
    
    /// 获取设备方向
    static var deviceOrientation: UIDeviceOrientation {
        return UIDevice.current.orientation
    }
    
    /// 是否为横屏
    static var isLandscape: Bool {
        return UIDevice.current.orientation.isLandscape
    }
    
    /// 是否为竖屏
    static var isPortrait: Bool {
        return UIDevice.current.orientation.isPortrait
    }
} 