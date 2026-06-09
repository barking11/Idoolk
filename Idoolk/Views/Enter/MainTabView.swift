import SwiftUI

struct MainTabView: View {
    @State private var selectedTab: Tab = .home
    @State private var hideTabBar: Bool = false
    @StateObject private var loadingManager = LoadingManager.shared
    
    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottom) {
                Group {
                    switch selectedTab {
                    case .home:
                        HomeView()
                    case .schedule:
                        StatusView()
                    case .profile:
                        ProfileView()
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .ignoresSafeArea(edges: .bottom)
                
                // Custom Tab Bar
                if !hideTabBar {
                    CustomTabBar(selectedTab: $selectedTab)
                        .transition(.move(edge: .bottom))
                }
            }
        }
        .ignoresSafeArea(.keyboard)
        .background(AppColors.background)
        // Hide TabBar when keyboard appears
        .onReceive(NotificationCenter.default.publisher(for: UIResponder.keyboardWillShowNotification)) { _ in
            withAnimation(.easeInOut) {
                hideTabBar = true
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: UIResponder.keyboardWillHideNotification)) { _ in
            withAnimation(.easeInOut) {
                hideTabBar = false
            }
        }
        // Global loading overlay
        .loading(
            isLoading: loadingManager.isLoading,
            customImage: loadingManager.customImage,
            message: loadingManager.message
        )
    }
}

#Preview {
    MainTabView()
}
