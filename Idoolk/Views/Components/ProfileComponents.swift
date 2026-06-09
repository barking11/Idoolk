import SwiftUI

// 用户头像组件
struct AvatarView: View {
    let imageUrl: String?
    let size: CGFloat
    
    var body: some View {
        if let imageUrl = imageUrl, !imageUrl.isEmpty {
            AsyncImage(url: URL(string: imageUrl)) { image in
                image
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            } placeholder: {
                Color.gray.opacity(0.2)
                    .overlay(
                        Image(systemName: "person.fill")
                            .font(.system(size: size/2.5))
                            .foregroundColor(.gray)
                    )
            }
            .frame(width: size, height: size)
            .clipShape(Circle())
        } else {
            Image("avatar_default")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: size, height: size)
        }
    }
}

// 个人信息头部组件
struct ProfileHeaderView: View {
    let name: String
    let avatarUrl: String?
    let level: Int
    @Binding var isEditing: Bool
    
    var body: some View {
        VStack(spacing: 15) {
            ZStack(alignment: .bottomTrailing) {
                AvatarView(imageUrl: avatarUrl, size: 90)
                
                //                    Image(systemName: "camera.fill")
                //                        .font(.system(size: 14))
                //                        .foregroundColor(.white)
                //                        .padding(8)
                //                        .background(AppColors.primary)
                //                        .clipShape(Circle())
                //                        .shadow(color: Color.black.opacity(0.2), radius: 2, x: 0, y: 1)
            }
            .padding(.top, 10)
            
            VStack(spacing: 6) {
                HStack(spacing: 6) {
                    Text(name)
                        .font(.system(size: 22, weight: .bold))
                        .foregroundColor(AppColors.text)
                }
                
                HStack(spacing: 3) {
                    Image("lv_1_icon")
                    
                    Text("·")
                        .foregroundColor(AppColors.secondaryText)
                    
                    Text("卡卡兔")
                        .font(.system(size: 13))
                        .foregroundColor(AppColors.secondaryText)
                }
                .padding(.top, 2)
            }
        }
        .frame(maxWidth: .infinity)
//        .padding(.bottom, 20)
//        .background(
//            LinearGradient(
//                gradient: Gradient(colors: [AppColors.background, AppColors.background.opacity(0.8)]),
//                startPoint: .bottom,
//                endPoint: .top
//            )
//        )
    }
}

// 设置/功能菜单项
struct ProfileMenuItem: View {
    let icon: String
    let title: String
    let subtitle: String?
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                Image(systemName: icon)
                    .font(.system(size: 18))
                    .foregroundColor(AppColors.primary)
                    .frame(width: 28, height: 28)
                    .background(AppColors.primary.opacity(0.15))
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.system(size: 16))
                        .foregroundColor(AppColors.text)
                    
                    if let subtitle = subtitle {
                        Text(subtitle)
                            .font(.system(size: 12))
                            .foregroundColor(AppColors.secondaryText)
                    }
                }
                .padding(.leading, 6)
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 14))
                    .foregroundColor(AppColors.secondaryText)
            }
            .padding(.vertical, 12)
            .padding(.horizontal)
            .contentShape(Rectangle())
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// 设置分组视图
struct ProfileMenuSection: View {
    let title: String
    let items: [ProfileMenuModel]
    let action: (String) -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(title)
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(AppColors.text)
                .padding(.horizontal)
                .padding(.vertical, 12)
            
            VStack(spacing: 0) {
                ForEach(items) { item in
                    VStack(spacing: 0) {
                        ProfileMenuItem(
                            icon: item.icon,
                            title: item.title,
                            subtitle: item.subtitle
                        ) {
                            action(item.id)
                        }
                        
                        if items.last?.id != item.id {
                            Divider()
                                .padding(.leading, 58)
                        }
                    }
                }
            }
            .background(AppColors.surface.opacity(0.6))
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .padding(.horizontal)
        }
    }
}

// 快捷操作项
struct QuickActionButton: View {
    let icon: String
    let title: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.system(size: 22))
                    .foregroundColor(AppColors.primary)
                    .frame(width: 50, height: 50)
                    .background(AppColors.primary.opacity(0.15))
                    .clipShape(Circle())
                
                Text(title)
                    .font(.system(size: 13))
                    .foregroundColor(AppColors.text)
            }
            .frame(maxWidth: .infinity)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// 菜单数据模型
struct ProfileMenuModel: Identifiable {
    let id: String
    let icon: String
    let title: String
    var subtitle: String?
    
    init(id: String, icon: String, title: String, subtitle: String? = nil) {
        self.id = id
        self.icon = icon
        self.title = title
        self.subtitle = subtitle
    }
}

// 菜单数据
struct ProfileMenuData {
    
    // 注意：设置项移到了ProfileView中，以便动态显示缓存大小
    static let settingsItems: [ProfileMenuModel] = [
        ProfileMenuModel(id: "feedback", icon: "exclamationmark.bubble.fill", title: "意见反馈", subtitle: nil)
    ]
    
    static let aboutItems: [ProfileMenuModel] = [
        ProfileMenuModel(id: "share", icon: "square.and.arrow.up.fill", title: "分享应用", subtitle: nil),
        ProfileMenuModel(id: "rate", icon: "star.fill", title: "评分鼓励", subtitle: nil),
        ProfileMenuModel(id: "terms", icon: "doc.text.fill", title: "用户协议", subtitle: nil),
        ProfileMenuModel(id: "privacy", icon: "hand.raised.fill", title: "隐私政策", subtitle: nil),
        ProfileMenuModel(id: "about", icon: "info.circle.fill", title: "关于我们", subtitle: "版本 \(Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0.0")")
    ]
}
