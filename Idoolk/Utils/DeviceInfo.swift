import SwiftUI
import UIKit

/// 设备信息工具类
struct DeviceInfo {
    // MARK: - 设备型号信息
    
    /// 设备名称（用户设置的名称）
    static var deviceName: String {
        return UIDevice.current.name
    }
    
    /// 设备型号标识符
    static var deviceModel: String {
        return UIDevice.current.model
    }
    
    /// 设备系统名称
    static var systemName: String {
        return UIDevice.current.systemName
    }
    
    /// 设备系统版本
    static var systemVersion: String {
        return UIDevice.current.systemVersion
    }
    
    /// 设备标识符
    static var identifier: String {
        return UIDevice.current.identifierForVendor?.uuidString ?? "Unknown"
    }
    
    // MARK: - 屏幕信息
    
    /// 屏幕分辨率（点）
    static var screenResolution: String {
        let screen = UIScreen.main
        return "\(Int(screen.bounds.width)) x \(Int(screen.bounds.height))"
    }
    
    /// 屏幕密度（像素每点）
    static var screenScale: CGFloat {
        return UIScreen.main.scale
    }
    
    /// 屏幕物理分辨率（像素）
    static var screenResolutionInPixels: String {
        let scale = UIScreen.main.scale
        let bounds = UIScreen.main.bounds
        let width = bounds.width * scale
        let height = bounds.height * scale
        return "\(Int(width)) x \(Int(height))"
    }
    
    // MARK: - 设备类型检测
    
    /// 是否为模拟器
    static var isSimulator: Bool {
        #if targetEnvironment(simulator)
        return true
        #else
        return false
        #endif
    }
    
    /// 是否为iPhone
    static var isPhone: Bool {
        return UIDevice.current.userInterfaceIdiom == .phone
    }
    
    /// 是否为iPad
    static var isPad: Bool {
        return UIDevice.current.userInterfaceIdiom == .pad
    }
    
    /// 是否为iPod touch
    static var isPod: Bool {
        return deviceModel.contains("iPod")
    }
    
    /// 是否为刘海屏设备（iPhone X或更新）
    static var hasNotch: Bool {
        if #available(iOS 11.0, *) {
            let keyWindow = UIApplication.shared.connectedScenes
                .filter({$0.activationState == .foregroundActive})
                .compactMap({$0 as? UIWindowScene})
                .first?.windows
                .filter({$0.isKeyWindow}).first
            
            return keyWindow?.safeAreaInsets.bottom ?? 0 > 0
        }
        return false
    }
    
    // MARK: - 存储信息
    
    /// 设备总存储空间（GB）
    static var totalDiskSpace: Double {
        do {
            let systemAttributes = try FileManager.default.attributesOfFileSystem(forPath: NSHomeDirectory())
            if let size = systemAttributes[.systemSize] as? NSNumber {
                return Double(truncating: size) / 1_000_000_000.0
            }
        } catch {}
        return 0
    }
    
    /// 设备可用存储空间（GB）
    static var freeDiskSpace: Double {
        do {
            let systemAttributes = try FileManager.default.attributesOfFileSystem(forPath: NSHomeDirectory())
            if let size = systemAttributes[.systemFreeSize] as? NSNumber {
                return Double(truncating: size) / 1_000_000_000.0
            }
        } catch {}
        return 0
    }
    
    // MARK: - 内存信息
    
    /// 设备总内存（GB）
    static var totalMemory: Double {
        let physicalMemory = ProcessInfo.processInfo.physicalMemory
        return Double(physicalMemory) / 1_000_000_000.0
    }
    
    /// 应用已使用内存（MB）
    static var usedMemory: Double {
        var taskInfo = task_vm_info_data_t()
        var count = mach_msg_type_number_t(MemoryLayout<task_vm_info>.size) / 4
        let result: kern_return_t = withUnsafeMutablePointer(to: &taskInfo) {
            $0.withMemoryRebound(to: integer_t.self, capacity: 1) {
                task_info(mach_task_self_, task_flavor_t(TASK_VM_INFO), $0, &count)
            }
        }
        
        if result == KERN_SUCCESS {
            return Double(taskInfo.phys_footprint) / 1_000_000.0
        }
        return 0
    }
    
    // MARK: - 电池信息
    
    /// 设备电池电量百分比
    static var batteryLevel: Double {
        UIDevice.current.isBatteryMonitoringEnabled = true
        return Double(UIDevice.current.batteryLevel) * 100
    }
    
    /// 设备电池状态
    static var batteryState: UIDevice.BatteryState {
        UIDevice.current.isBatteryMonitoringEnabled = true
        return UIDevice.current.batteryState
    }
    
    /// 电池状态描述
    static var batteryStateString: String {
        let state = batteryState
        switch state {
        case .charging: return "充电中"
        case .full: return "已充满"
        case .unplugged: return "使用电池中"
        case .unknown: return "未知"
        @unknown default: return "未知"
        }
    }
} 