//
//  IdoolkApp.swift
//  Idoolk
//
//  Created by wang k on 2025/3/18.
//

import SwiftUI
import SwiftData
import MessageUI

@main
struct IdoolkApp: App {
    init() {
        LoadingManager.shared.customImage = "loading_icon"

        configureTransparentTabBar()
        
        // 应用启动时清理过期缓存
        CacheManager.shared.cleanExpiredCache { success in
            if success {
                print("过期缓存清理成功")
            }
        }
    }
    
    private func configureTransparentTabBar() {
        let appearance = UITabBarAppearance()
        appearance.configureWithTransparentBackground() // 设置为透明背景
        
        // 如果您想要完全透明（不显示模糊效果）
        appearance.backgroundEffect = nil
        appearance.backgroundColor = UIColor.clear
        
        // 应用到 UITabBar
        UITabBar.appearance().standardAppearance = appearance
        
        // iOS 15 及以上还需要设置 scrollEdgeAppearance
        if #available(iOS 15.0, *) {
            UITabBar.appearance().scrollEdgeAppearance = appearance
        }
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(RealmManager.shared)
                .environmentObject(AppState())
                .modelContainer(RealmManager.shared.modelContainer)
        }
    }
}

// 全局应用状态管理
class AppState: ObservableObject {
    @Published var needsRefresh: Bool = false
    
    init() {
        // 监听应用程序从后台进入前台的通知
        NotificationCenter.default.addObserver(self, selector: #selector(appWillEnterForeground), name: UIApplication.willEnterForegroundNotification, object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    // 应用程序从后台进入前台时触发刷新
    @objc private func appWillEnterForeground() {
        needsRefresh = true
        
        // 重置状态，以便下次可以再次触发
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.needsRefresh = false
        }
    }
}
