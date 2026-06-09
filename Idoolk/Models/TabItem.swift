import SwiftUI

enum Tab: String, CaseIterable {
    case home = "首页"
    case schedule = "追剧"
    case profile = "我的"
    
    var iconName: String {
        switch self {
        case .home:
            return "tab_home_normal"
        case .profile:
            return "tab_user_normal"
        case .schedule:
            return "tab_schedule_normal"
        }
    }
    
    var selectedIconName: String {
        switch self {
        case .home:
            return "tab_home_normal"
        case .profile:
            return "tab_user_normal"
        case .schedule:
            return "tab_schedule_normal"
        }
    }
    
    var index: Int {
        return Tab.allCases.firstIndex(of: self) ?? 0
    }
}
