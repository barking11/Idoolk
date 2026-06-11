import UIKit

extension UIApplication {
    var gdtActiveKeyWindow: UIWindow? {
        connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .flatMap(\.windows)
            .first { $0.isKeyWindow }
    }

    func gdtTopViewController(base: UIViewController? = UIApplication.shared.gdtActiveKeyWindow?.rootViewController) -> UIViewController? {
        if let navigationController = base as? UINavigationController {
            return gdtTopViewController(base: navigationController.visibleViewController)
        }
        if let tabBarController = base as? UITabBarController {
            return gdtTopViewController(base: tabBarController.selectedViewController)
        }
        if let presented = base?.presentedViewController {
            return gdtTopViewController(base: presented)
        }
        return base
    }
}

extension String {
    var isPlaceholderGDTId: Bool {
        isEmpty || hasPrefix("YOUR_GDT_")
    }
}
