import CoreGraphics

enum GDTAdConfig {
    static var appId = "YOUR_GDT_APP_ID"

    enum PlacementId {
        static var splash = "YOUR_GDT_SPLASH_PLACEMENT_ID"
        static var banner = "YOUR_GDT_BANNER_PLACEMENT_ID"
        static var native = "YOUR_GDT_NATIVE_PLACEMENT_ID"
        static var interstitial = "YOUR_GDT_INTERSTITIAL_PLACEMENT_ID"
        static var rewarded = "YOUR_GDT_REWARDED_PLACEMENT_ID"
    }

    enum Layout {
        static let bannerHeight: CGFloat = 60
        static let nativeHeight: CGFloat = 280
        static let splashFetchDelay: CGFloat = 5
    }
}
