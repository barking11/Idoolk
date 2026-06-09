import SwiftUI

struct CustomTabBar: View {
    @Binding var selectedTab: Tab
    
    // For animation
    @State private var xOffset: CGFloat = 0
    
    var body: some View {
        HStack(spacing: 0) {
            ForEach(Tab.allCases, id: \.rawValue) { tab in
                GeometryReader { geometry in
                    Button(action: {
                        withAnimation(.spring(response: 0.35, dampingFraction: 0.78)) {
                            selectedTab = tab
                        }
                    }) {
                        let isSelected = selectedTab == tab
                        
                        VStack(spacing: 4) {
                            Image(isSelected ? tab.selectedIconName : tab.iconName)
                                .renderingMode(.template) // 允许着色
                                .resizable()
                                .scaledToFit()
                                .frame(width: 23, height: 23)
                                .foregroundColor(isSelected ? AppColors.tabBarSelected : AppColors.tabBarUnselected)
                            
                            Text(tab.rawValue)
                                .font(.system(size: 10, weight: isSelected ? .bold : .semibold))
                        }
                        .foregroundColor(isSelected ? AppColors.tabBarSelected : AppColors.tabBarUnselected)
                        .frame(width: geometry.size.width, height: 58)
                        .background {
                            if isSelected {
                                Capsule()
                                    .fill(.white.opacity(0.13))
                                    .overlay(
                                        Capsule()
                                            .stroke(.white.opacity(0.22), lineWidth: 0.8)
                                    )
                                    .shadow(color: AppColors.tabBarSelected.opacity(0.18), radius: 8, x: 0, y: 2)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 7)
                                    .transition(.scale(scale: 0.82).combined(with: .opacity))
                            }
                        }
                        .contentShape(Rectangle())
                    }
                    .buttonStyle(PlainButtonStyle())
                    .onAppear {
                        if tab == .home {
                            xOffset = geometry.frame(in: .global).minX
                        }
                    }
                }
                .frame(height: 58)
            }
        }
        .frame(height: 58)
        .background(
            RoundedRectangle(cornerRadius: 29, style: .continuous)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 29, style: .continuous)
                        .fill(
                            LinearGradient(
                                colors: [
                                    .white.opacity(0.18),
                                    AppColors.tabBarBackground.opacity(0.42),
                                    .black.opacity(0.18)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                )
                .overlay(alignment: .topLeading) {
                    RoundedRectangle(cornerRadius: 29, style: .continuous)
                        .stroke(
                            LinearGradient(
                                colors: [
                                    .white.opacity(0.46),
                                    .white.opacity(0.08),
                                    AppColors.tabBarSelected.opacity(0.24)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 0.8
                        )
                }
                .shadow(color: Color.black.opacity(0.24), radius: 12, x: 0, y: 5)
                .shadow(color: AppColors.tabBarSelected.opacity(0.06), radius: 12, x: 0, y: -2)
        )
        .padding(.horizontal, 20)
    }
}

#Preview {
    VStack {
        Spacer()
        CustomTabBar(selectedTab: .constant(.home))
    }
    .background(AppColors.background)
    .ignoresSafeArea()
}
