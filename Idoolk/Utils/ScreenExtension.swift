import SwiftUI

// MARK: - 屏幕尺寸相关扩展
extension View {
    /// 全屏宽度
    func fullScreenWidth() -> some View {
        self.frame(width: UIHelper.screenWidth)
    }
    
    /// 全屏高度
    func fullScreenHeight() -> some View {
        self.frame(height: UIHelper.screenHeight)
    }
    
    /// 忽略顶部安全区域
    func ignoreTopSafeArea() -> some View {
        self.padding(.top, -UIHelper.topSafeAreaInset)
            .ignoresSafeArea(.all, edges: .top)
    }
    
    /// 忽略底部安全区域
    func ignoreBottomSafeArea() -> some View {
        self.padding(.bottom, -UIHelper.bottomSafeAreaInset)
            .ignoresSafeArea(.all, edges: .bottom)
    }
    
    /// 添加底部安全区域padding
    func addBottomSafeAreaPadding() -> some View {
        self.padding(.bottom, UIHelper.bottomSafeAreaInset)
    }
    
    /// 添加顶部安全区域padding
    func addTopSafeAreaPadding() -> some View {
        self.padding(.top, UIHelper.topSafeAreaInset)
    }
    
    /// 添加TabBar高度的底部间距
    func addTabBarBottomPadding() -> some View {
        self.padding(.bottom, UIHelper.tabBarTotalHeight)
    }
    
    /// 添加导航栏高度的顶部间距
    func addNavigationBarTopPadding() -> some View {
        self.padding(.top, UIHelper.navigationBarTotalHeight)
    }
    
    /// 自适应缩放尺寸
    func adaptiveFrame(width: CGFloat? = nil, height: CGFloat? = nil, alignment: Alignment = .center) -> some View {
        self.frame(
            width: width != nil ? UIHelper.adaptiveSize(width!) : nil,
            height: height != nil ? UIHelper.adaptiveSize(height!) : nil,
            alignment: alignment
        )
    }
    
    /// 适配不同设备的padding
    func adaptivePadding(_ edges: Edge.Set = .all, _ length: CGFloat? = nil) -> some View {
        let adaptiveLength = length != nil ? UIHelper.adaptiveSize(length!) : nil
        return self.padding(edges, adaptiveLength)
    }
}

// MARK: - 设备屏幕尺寸扩展
extension CGFloat {
    /// 屏幕宽度比例
    static var screenWidthRatio: CGFloat {
        return UIHelper.screenWidth / 390.0 // 基于iPhone 12/13/14的宽度
    }
    
    /// 屏幕高度比例
    static var screenHeightRatio: CGFloat {
        return UIHelper.screenHeight / 844.0 // 基于iPhone 12/13/14的高度
    }
    
    /// 按屏幕宽度比例缩放
    var scaled: CGFloat {
        return self * CGFloat.screenWidthRatio
    }
    
    /// 根据是否为iPad缩放
    var scaledForDevice: CGFloat {
        return UIHelper.isIPad ? self * 1.3 : self
    }
}

// MARK: - 颜色透明度扩展
extension Color {
    /// 返回指定透明度的颜色
    func withOpacity(_ opacity: Double) -> Color {
        return self.opacity(opacity)
    }
    
    /// 获取较亮的颜色变体
    func lighter(by percentage: CGFloat = 30.0) -> Color {
        return self.opacity(1.0 - percentage / 100.0)
    }
    
    /// 获取较暗的颜色变体
    func darker(by percentage: CGFloat = 30.0) -> Color {
        return self.opacity(1.0 + percentage / 100.0)
    }
} 