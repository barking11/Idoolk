import SwiftUI
import Combine
import MessageUI
import StoreKit

// 邮件发送视图封装
struct MailView: UIViewControllerRepresentable {
    @Binding var isShowing: Bool
    @Binding var result: Result<MFMailComposeResult, Error>?
    
    let toRecipients: [String]
    let subject: String
    let messageBody: String
    
    class Coordinator: NSObject, MFMailComposeViewControllerDelegate {
        @Binding var isShowing: Bool
        @Binding var result: Result<MFMailComposeResult, Error>?
        
        init(isShowing: Binding<Bool>, result: Binding<Result<MFMailComposeResult, Error>?>) {
            _isShowing = isShowing
            _result = result
        }
        
        func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
            defer {
                isShowing = false
            }
            
            if let error = error {
                self.result = .failure(error)
                return
            }
            self.result = .success(result)
        }
    }
    
    func makeCoordinator() -> Coordinator {
        return Coordinator(isShowing: $isShowing, result: $result)
    }
    
    func makeUIViewController(context: Context) -> MFMailComposeViewController {
        let mailComposer = MFMailComposeViewController()
        mailComposer.mailComposeDelegate = context.coordinator
        mailComposer.setToRecipients(toRecipients)
        mailComposer.setSubject(subject)
        mailComposer.setMessageBody(messageBody, isHTML: false)
        return mailComposer
    }
    
    func updateUIViewController(_ uiViewController: MFMailComposeViewController, context: Context) {}
}

struct ProfileView: View {
    // 用户数据
    @State private var userName = "月亮镇军团TAN"
    @State private var userAvatar: String? = nil
    @State private var level = 1
    
    // 缓存数据
    @State private var cacheSize: Double = 0.0
    @State private var isLoadingCache: Bool = false
    @State private var isClearingCache: Bool = false
    
    // 邮件反馈
    @State private var isShowingMailView = false
    @State private var mailResult: Result<MFMailComposeResult, Error>? = nil
    
    // 状态管理
    @State private var isEditing = false
    @State private var showingSheet: String? = nil
    @State private var showingAlert = false
    @State private var alertTitle = ""
    @State private var alertMessage = ""
    
    // 设置项
    private var settingsItems: [ProfileMenuModel] {
        return [
            ProfileMenuModel(id: "clearCache", icon: "trash.fill", title: "清除缓存", subtitle: "当前缓存: \(String(format: "%.1f", cacheSize))MB"),
            ProfileMenuModel(id: "feedback", icon: "exclamationmark.bubble.fill", title: "意见反馈", subtitle: nil)
        ]
    }
    
    // 应用分享信息
    private let appStoreURL = "https://apps.apple.com/app/idxxxxxx" // 替换为实际的App Store链接
    private var appName: String {
        return Bundle.main.infoDictionary?["CFBundleDisplayName"] as? String ??
               Bundle.main.infoDictionary?["CFBundleName"] as? String ??
               "追剧兔"
    }
    private let feedbackEmail = "supportidok@163.com"
    
    var body: some View {
        ZStack {
            // 背景色
            AppColors.background.ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 0) {
                    ZStack(alignment: .bottom) {
                        Image("profile_bg")
                            .resizable()
                            .scaledToFill()
                            .clipped()
                        
                        // 用户头部信息
                        ProfileHeaderView(
                            name: userName,
                            avatarUrl: userAvatar,
                            level: level,
                            isEditing: $isEditing
                        )
                        .padding(.bottom, -55)
                        
                        //                        VStack {
                        //                            Spacer()
                        //
                        //                            // 用户头部信息
                        //                            ProfileHeaderView(
                        //                                name: userName,
                        //                                avatarUrl: userAvatar,
                        //                                level: level,
                        //                                isEditing: $isEditing
                        //                            )
                        //                            .padding(.bottom, -60)
                        //                        }
                        
                    }
                    .padding(.bottom, 80)
                    
                    ProfileMenuSection(
                        title: "设置与工具",
                        items: settingsItems,
                        action: handleMenuAction
                    )
                    .padding(.bottom, 20)
                    
                    ProfileMenuSection(
                        title: "关于应用",
                        items: ProfileMenuData.aboutItems,
                        action: handleMenuAction
                    )
                    .padding(.bottom, 100)
                }
            }
        }
        .ignoresSafeArea()
        .navigationBarHidden(true)
        .fullScreenCover(item: $showingSheet, content: { item in
            sheetView(for: item)
        })
        .alert(isPresented: $showingAlert) {
            Alert(
                title: Text(alertTitle),
                message: Text(alertMessage),
                dismissButton: .default(Text("确定"))
            )
        }
        .sheet(isPresented: $isEditing) {
            //            ProfileEditView(
            //                userName: $userName,
            //                userAvatar: $userAvatar,
            //                level: $level
            //            )
        }
        .sheet(isPresented: $isShowingMailView) {
            if MFMailComposeViewController.canSendMail() {
                MailView(
                    isShowing: $isShowingMailView,
                    result: $mailResult,
                    toRecipients: [feedbackEmail],
                    subject: "意见反馈 - \(appName)",
                    messageBody: "请在此处输入您的反馈意见：\n\n\n\n\n设备信息：\niOS \(UIDevice.current.systemVersion)\n设备型号：\(UIDevice.current.model)"
                )
            } else {
                ZStack {
                    AppColors.background.ignoresSafeArea()
                    VStack(spacing: 20) {
                        Image(systemName: "xmark.circle")
                            .font(.system(size: 60))
                            .foregroundColor(AppColors.secondaryText)
                        
                        Text("无法发送邮件")
                            .font(.title3)
                            .fontWeight(.bold)
                            .foregroundColor(AppColors.text)
                        
                        Text("您的设备未设置邮件账户，请设置后再试。")
                            .multilineTextAlignment(.center)
                            .foregroundColor(AppColors.secondaryText)
                            .padding(.horizontal, 30)
                        
                        Button("关闭") {
                            isShowingMailView = false
                        }
                        .padding(.horizontal, 40)
                        .padding(.vertical, 12)
                        .background(AppColors.primary)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                        .padding(.top, 20)
                    }
                    .padding()
                }
            }
        }
        .onAppear {
            updateCacheSize()
        }
    }
    
    // 更新缓存大小
    private func updateCacheSize() {
        isLoadingCache = true
        CacheManager.shared.getCacheSize { size in
            self.cacheSize = size
            self.isLoadingCache = false
        }
    }
    
    // 对应表单页面
    @ViewBuilder
    private func sheetView(for item: String) -> some View {
        switch item {
        case "terms":
            LegalDocumentView(title: "用户协议", content: termsText)
        case "privacy":
            LegalDocumentView(title: "隐私政策", content: privacyText)
        case "about":
            AboutView()
        default:
            EmptyView()
        }
    }
    
    // 处理菜单点击
    private func handleMenuAction(id: String) {
        switch id {
        case "clearCache":
            clearCache()
        case "feedback":
            showFeedback()
        case "share":
            shareApp()
        case "rate":
            rateApp()
        case "terms", "privacy", "about", "vip":
            showingSheet = id
        default:
            showInfo(title: "功能开发中", message: "该功能正在开发中，敬请期待")
        }
    }
    
    // 处理快捷操作点击
    private func handleQuickAction(index: Int) {
        let actions = ["favorites", "history", "download", "coupons"]
        if index < actions.count {
            handleMenuAction(id: actions[index])
        }
    }
    
    // 清除缓存
    private func clearCache() {
        // 显示加载状态
//        isClearingCache = true
        
        LoadingManager.shared.showLoading(message: "正在清理缓存...")
        
        // 获取当前缓存大小（用于显示清理了多少空间）
        let currentSize = cacheSize
        
        // 调用CacheManager清除缓存
        CacheManager.shared.clearCache { success in
            
            LoadingManager.shared.hideLoading()
            
            if success {
                // 清除成功，更新缓存大小
                CacheManager.shared.getCacheSize { newSize in
                    // 更新缓存大小
                    self.cacheSize = newSize
                    
                    // 显示清理结果
//                    alertTitle = "清除缓存成功"
//                    alertMessage = "已释放\(String(format: "%.1f", currentSize - newSize))MB空间"
//                    showingAlert = true
                }
            } else {
                // 清除失败
                isClearingCache = false
                alertTitle = "清除缓存"
                alertMessage = "缓存清除失败，请稍后再试"
                showingAlert = true
            }
        }
    }
    
    // 显示意见反馈
    private func showFeedback() {
        // 检查是否可以发送邮件
        if MFMailComposeViewController.canSendMail() {
            isShowingMailView = true
        } else {
            // 如果不能发送邮件，显示备用选项
            let alert = UIAlertController(
                title: "无法发送邮件",
                message: "您的设备未设置邮件账户，是否复制反馈邮箱地址？",
                preferredStyle: .alert
            )
            
            // 添加复制邮箱选项
            alert.addAction(UIAlertAction(title: "复制邮箱", style: .default) { _ in
                UIPasteboard.general.string = self.feedbackEmail
                self.showInfo(title: "已复制", message: "邮箱地址已复制到剪贴板")
            })
            
            // 添加取消选项
            alert.addAction(UIAlertAction(title: "取消", style: .cancel))
            
            // 显示警告框
            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
               let rootViewController = windowScene.windows.first?.rootViewController {
                rootViewController.present(alert, animated: true)
            }
        }
    }
    
    // 分享应用
    private func shareApp() {
        // 配置分享内容
        let shareText = "\(appName) - 你的追剧新伙伴！快来下载体验吧！"
        let shareURL = URL(string: appStoreURL) ?? URL(string: "https://apps.apple.com")!
        
        // 创建UIActivityViewController用于分享
        let activityItems: [Any] = [shareText, shareURL]
        let activityVC = UIActivityViewController(
            activityItems: activityItems,
            applicationActivities: nil
        )
        
        // 在iPad上需要设置弹出源视图
        if UIDevice.current.userInterfaceIdiom == .pad {
            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
               let rootViewController = windowScene.windows.first?.rootViewController {
                activityVC.popoverPresentationController?.sourceView = rootViewController.view
                activityVC.popoverPresentationController?.sourceRect = CGRect(x: UIScreen.main.bounds.width / 2, y: UIScreen.main.bounds.height / 2, width: 0, height: 0)
                activityVC.popoverPresentationController?.permittedArrowDirections = []
                rootViewController.present(activityVC, animated: true)
            }
        } else {
            // 在iPhone上直接呈现
            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
               let rootViewController = windowScene.windows.first?.rootViewController {
                rootViewController.present(activityVC, animated: true)
            }
        }
    }
    
    // 评分应用
    private func rateApp() {
        // 使用StoreKit请求评分
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
            if #available(iOS 14.0, *) {
                // iOS 14及以上使用新API
                SKStoreReviewController.requestReview(in: windowScene)
            } else {
                // iOS 14以下使用旧API
                SKStoreReviewController.requestReview()
            }
        }
    }
    
    // 显示信息
    private func showInfo(title: String, message: String) {
        alertTitle = title
        alertMessage = message
        showingAlert = true
    }
    
    // 协议文本
    private let termsText = """
    用户协议
    
    欢迎使用Idoolk服务。本协议是您与Idoolk应用之间关于使用Idoolk服务所订立的协议。
    
    一、服务条款的确认和接纳
    通过访问或使用Idoolk，您确认已阅读、理解并同意受本协议条款的约束。如您不同意本协议任何条款，请立即停止使用本应用。
    
    二、服务内容
    Idoolk为用户提供在线影视内容浏览、搜索、收藏等服务。
    
    三、用户账号
    1. 用户须对在Idoolk上的注册信息的真实性、合法性、有效性承担全部责任。
    2. 用户须保护自己的账号和密码安全，因用户疏忽导致的任何损失由用户自行承担。
    
    四、用户行为规范
    1. 用户不得利用Idoolk从事违法和不良行为。
    2. 用户不得干扰Idoolk的正常运营。
    
    五、知识产权
    Idoolk及其内容的所有权归Idoolk所有，用户仅获得非独家、不可转让的使用权。
    
    六、免责声明
    在法律允许的最大范围内，Idoolk不对任何直接、间接、偶然、特殊及后续的损害承担责任。
    
    七、协议修改
    Idoolk有权在必要时修改本协议条款，修改后的协议会在应用内公布。
    
    八、法律管辖
    本协议的解释、效力及纠纷的解决，适用中华人民共和国法律。
    """
    
    // 隐私政策文本
    private let privacyText = """
    隐私政策
    
    本隐私政策描述了Idoolk如何收集、使用和分享您的个人信息。
    
    一、信息收集
    1. 我们收集的信息包括：账号信息、设备信息、使用记录等。
    2. 我们通过cookies和类似技术收集信息。
    
    二、信息使用
    1. 提供、维护和改进我们的服务。
    2. 发送通知、更新和营销信息。
    3. 分析使用趋势和偏好。
    
    三、信息共享
    1. 在征得您同意的情况下与第三方共享。
    2. 遵从法律要求时进行披露。
    
    四、信息安全
    我们采取合理措施保护您的个人信息安全。
    
    五、您的权利
    您有权访问、更正或删除您的个人信息。
    
    六、儿童隐私
    我们的服务不面向13岁以下儿童。
    
    七、政策更新
    我们可能会更新本隐私政策，更新后会在应用内通知您。
    
    八、联系我们
    如有任何问题，请通过应用内的反馈功能联系我们。
    """
}

// 修改 Optional 扩展为正确的形式
extension String: Identifiable {
    public var id: String { self }
}

// 用户编辑页面
struct ProfileEditView: View {
    @Binding var userName: String
    @Binding var userAvatar: String?
    @Binding var isVip: Bool
    @Binding var level: Int
    
    @State private var editName: String = ""
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            VStack {
                Form {
                    Section(header: Text("个人信息")) {
                        HStack {
                            Text("头像")
                            Spacer()
                            AvatarView(imageUrl: userAvatar, size: 60)
                        }
                        
                        TextField("昵称", text: $editName)
                    }
                    
                    Section {
                        Button("保存") {
                            if !editName.isEmpty {
                                userName = editName
                            }
                            presentationMode.wrappedValue.dismiss()
                        }
                        .frame(maxWidth: .infinity)
                        .foregroundColor(.blue)
                    }
                }
            }
            .navigationTitle("编辑个人信息")
            .navigationBarItems(
                trailing: Button("取消") {
                    presentationMode.wrappedValue.dismiss()
                }
            )
            .onAppear {
                editName = userName
            }
        }
    }
}

// 法律文档页面
struct LegalDocumentView: View {
    let title: String
    let content: String
    
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            ZStack {
                AppColors.background.ignoresSafeArea()
                
                ScrollView {
                    Text(content)
                        .font(.system(size: 14))
                        .foregroundColor(AppColors.text)
                        .padding()
                }
            }
            .navigationBarTitle(title, displayMode: .inline)
            .navigationBarItems(
                trailing: Button(action: {
                    presentationMode.wrappedValue.dismiss()
                }) {
                    Text("关闭")
                        .foregroundColor(AppColors.primary)
                }
            )
        }
    }
}

// 关于我们页面
struct AboutView: View {
    @Environment(\.presentationMode) var presentationMode
    
    // 获取应用版本号
    private var appVersion: String {
        return Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0.0"
    }
    
    // 获取构建号
    private var buildNumber: String {
        return Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1"
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                AppColors.background.ignoresSafeArea()
                
                VStack(spacing: 30) {
                    Spacer()
                    
                    Image("avatar_default")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 100, height: 100)
                    
                    VStack(spacing: 8) {
                        Text("追剧兔")
                            .font(.system(size: 28, weight: .bold))
                            .foregroundColor(AppColors.text)
                        
                        Text("版本 \(appVersion) (\(buildNumber))")
                            .font(.system(size: 14))
                            .foregroundColor(AppColors.secondaryText)
                    }
                    
                    VStack(spacing: 16) {
                        aboutRow(icon: "envelope.fill", title: "联系我们", detail: "supportidok@163.com")
//                        aboutRow(icon: "phone.fill", title: "客服热线", detail: "400-123-4567")
                    }
                    .padding()
                    .background(AppColors.surface.opacity(0.6))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .padding(.horizontal)
                    
                    Text("© \(Calendar.current.component(.year, from: Date())) Idoolk. 保留所有权利。")
                        .font(.system(size: 12))
                        .foregroundColor(AppColors.secondaryText)
                        .padding(.top, 40)
                    
                    Spacer()
                }
                .padding()
            }
            .navigationBarTitle("关于我们", displayMode: .inline)
            .navigationBarItems(
                trailing: Button(action: {
                    presentationMode.wrappedValue.dismiss()
                }) {
                    Text("关闭")
                        .foregroundColor(AppColors.primary)
                }
            )
        }
    }
    
    private func aboutRow(icon: String, title: String, detail: String) -> some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(AppColors.primary)
                .frame(width: 24)
            
            Text(title)
                .foregroundColor(AppColors.text)
            
            Spacer()
            
            Text(detail)
                .foregroundColor(AppColors.secondaryText)
        }
        .padding(.vertical, 8)
    }
}

#Preview {
    NavigationView {
        ProfileView()
    }
}
