import SwiftUI

// MARK: - 卡片样式修饰器
struct CardStyle: ViewModifier {
    var backgroundColor: Color = AppColors.surface
    var cornerRadius: CGFloat = UIHelper.standardCornerRadius
    var shadowRadius: CGFloat = 4
    
    func body(content: Content) -> some View {
        content
            .background(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .fill(backgroundColor)
                    .shadow(color: Color.black.opacity(0.1), radius: shadowRadius, x: 0, y: 2)
            )
    }
}

// MARK: - 毛玻璃背景修饰器
struct GlassBackground: ViewModifier {
    var opacity: Double = 0.7
    var blurRadius: CGFloat = 8
    var cornerRadius: CGFloat = UIHelper.standardCornerRadius
    
    func body(content: Content) -> some View {
        content
            .background(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .fill(AppColors.surface.opacity(opacity))
                    .background(
                        Blur(style: .systemUltraThinMaterial)
                            .cornerRadius(cornerRadius)
                    )
            )
    }
}

// MARK: - 高斯模糊修饰器
struct Blur: UIViewRepresentable {
    var style: UIBlurEffect.Style
    
    func makeUIView(context: Context) -> UIVisualEffectView {
        return UIVisualEffectView(effect: UIBlurEffect(style: style))
    }
    
    func updateUIView(_ uiView: UIVisualEffectView, context: Context) {
        uiView.effect = UIBlurEffect(style: style)
    }
}

// MARK: - 阴影修饰器
struct StandardShadow: ViewModifier {
    var radius: CGFloat = 5
    var opacity: Double = 0.2
    
    func body(content: Content) -> some View {
        content
            .shadow(color: Color.black.opacity(opacity), radius: radius, x: 0, y: 2)
    }
}

// MARK: - 按钮样式修饰器
struct PrimaryButtonStyle: ViewModifier {
    var isEnabled: Bool = true
    
    func body(content: Content) -> some View {
        content
            .padding(.horizontal, 20)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: UIHelper.standardCornerRadius)
                    .fill(isEnabled ? AppColors.primary : AppColors.primary.opacity(0.5))
            )
            .foregroundColor(.white)
            .font(.system(size: 16, weight: .semibold))
    }
}

// MARK: - 渐变背景修饰器
struct GradientBackground: ViewModifier {
    var colors: [Color]
    var startPoint: UnitPoint
    var endPoint: UnitPoint
    
    func body(content: Content) -> some View {
        content
            .background(
                LinearGradient(
                    gradient: Gradient(colors: colors),
                    startPoint: startPoint,
                    endPoint: endPoint
                )
            )
    }
}

// MARK: - 标题文本样式修饰器
struct TitleTextStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .font(.system(size: 22, weight: .bold))
            .foregroundColor(AppColors.text)
    }
}

// MARK: - 副标题文本样式修饰器
struct SubtitleTextStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .font(.system(size: 18, weight: .semibold))
            .foregroundColor(AppColors.text)
    }
}

// MARK: - 正文文本样式修饰器
struct BodyTextStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .font(.system(size: 15))
            .foregroundColor(AppColors.text)
    }
}

// MARK: - 扩展View应用修饰器
extension View {
    /// 应用卡片样式
    func cardStyle(backgroundColor: Color = AppColors.surface, cornerRadius: CGFloat = UIHelper.standardCornerRadius, shadowRadius: CGFloat = 4) -> some View {
        self.modifier(CardStyle(backgroundColor: backgroundColor, cornerRadius: cornerRadius, shadowRadius: shadowRadius))
    }
    
    /// 应用毛玻璃背景
    func glassBackground(opacity: Double = 0.7, blurRadius: CGFloat = 8, cornerRadius: CGFloat = UIHelper.standardCornerRadius) -> some View {
        self.modifier(GlassBackground(opacity: opacity, blurRadius: blurRadius, cornerRadius: cornerRadius))
    }
    
    /// 应用标准阴影
    func standardShadow(radius: CGFloat = 5, opacity: Double = 0.2) -> some View {
        self.modifier(StandardShadow(radius: radius, opacity: opacity))
    }
    
    /// 应用主要按钮样式
    func primaryButtonStyle(isEnabled: Bool = true) -> some View {
        self.modifier(PrimaryButtonStyle(isEnabled: isEnabled))
    }
    
    /// 应用渐变背景
    func gradientBackground(colors: [Color], startPoint: UnitPoint = .topLeading, endPoint: UnitPoint = .bottomTrailing) -> some View {
        self.modifier(GradientBackground(colors: colors, startPoint: startPoint, endPoint: endPoint))
    }
    
    /// 应用标题文本样式
    func titleTextStyle() -> some View {
        self.modifier(TitleTextStyle())
    }
    
    /// 应用副标题文本样式
    func subtitleTextStyle() -> some View {
        self.modifier(SubtitleTextStyle())
    }
    
    /// 应用正文文本样式
    func bodyTextStyle() -> some View {
        self.modifier(BodyTextStyle())
    }
} 