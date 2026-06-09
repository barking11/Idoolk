import SwiftUI

struct LoadingView: View {
    var customImage: String? = nil
    var message: String? = nil
    @State private var isAnimating = false
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.4)
                .edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 20) {
                if let customImage = customImage {
                    // Custom image with rotation animation
                    Image(customImage)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 30, height: 30)
                        .rotationEffect(Angle(degrees: isAnimating ? 360 : 0))
                        .animation(
                            Animation.linear(duration: 2.0)
                                .repeatForever(autoreverses: false),
                            value: isAnimating
                        )
                        .onAppear {
                            isAnimating = true
                        }
                } else {
                    // Default loading indicator
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: AppColors.primary))
                        .scaleEffect(2)
                }
                
                if let message = message {
                    Text(message)
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(AppColors.text)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }
            }
            .padding(20)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(AppColors.surface)
                    .shadow(color: Color.black.opacity(0.2), radius: 10)
            )
        }
    }
}

struct LoadingModifier: ViewModifier {
    let isLoading: Bool
    let customImage: String?
    let message: String?
    
    func body(content: Content) -> some View {
        ZStack {
            content
            
            if isLoading {
                LoadingView(customImage: customImage, message: message)
            }
        }
    }
}

extension View {
    func loading(isLoading: Bool, customImage: String? = nil, message: String? = nil) -> some View {
        modifier(LoadingModifier(isLoading: isLoading, customImage: customImage, message: message))
    }
}

#Preview {
    ZStack {
        Color.gray.opacity(0.3).edgesIgnoringSafeArea(.all)
        VStack(spacing: 20) {
            Button("Show Default Loading") {}
                .padding()
            Button("Show Custom Loading") {}
                .padding()
        }
    }
    .loading(isLoading: true, message: "加载中...")
} 
