import Foundation
@preconcurrency import GDTMobSDK
import UIKit

@MainActor
final class GDTAdService: NSObject {
    static let shared = GDTAdService()

    private var isStarted = false
    private var splashAd: GDTSplashAd?
    private var splashWindow: UIWindow?
    private var splashBottomView: UIView?
    private var interstitialAd: GDTUnifiedInterstitialAd?
    private var rewardedAd: GDTRewardVideoAd?
    private var shouldShowRewardedOnLoad = false
    private var rewardedCompletion: ((Bool) -> Void)?

    private override init() {
        super.init()
    }

    func start(appId: String = GDTAdConfig.appId) {
        guard !isStarted, !appId.isPlaceholderAdId else { return }

        GDTSDKConfig.initWithAppId(appId)
        GDTSDKConfig.start { [weak self] success, error in
            Task { @MainActor in
                if let error {
                    print("GDT SDK start failed: \(error)")
                }
                self?.isStarted = success
            }
        }
    }

    func showSplash(
        placementId: String = GDTAdConfig.PlacementId.splash,
        in window: UIWindow? = nil,
        bottomView: UIView? = nil
    ) {
        guard !placementId.isPlaceholderAdId, let window = window ?? UIApplication.shared.gdtActiveKeyWindow else { return }

        guard let splashAd = GDTSplashAd(placementId: placementId) else { return }
        splashAd.delegate = self
        splashAd.fetchDelay = GDTAdConfig.Layout.splashFetchDelay
        splashAd.backgroundColor = UIColor(AppColors.background)
        self.splashAd = splashAd
        self.splashWindow = window
        self.splashBottomView = bottomView ?? UIView(frame: .zero)

        splashAd.load()
    }

    func showInterstitial(
        placementId: String = GDTAdConfig.PlacementId.interstitial,
        from rootViewController: UIViewController? = nil
    ) {
        guard !placementId.isPlaceholderAdId else { return }

        let ad = GDTUnifiedInterstitialAd(placementId: placementId)
        ad.delegate = self
        interstitialAd = ad
        ad.load()

        if let rootViewController = rootViewController ?? UIApplication.shared.gdtTopViewController(), ad.isAdValid {
            ad.present(fromRootViewController: rootViewController)
        }
    }

    func preloadRewarded(
        placementId: String = GDTAdConfig.PlacementId.rewarded
    ) {
        guard !placementId.isPlaceholderAdId else { return }

        let ad = GDTRewardVideoAd(placementId: placementId)
        ad.delegate = self
        rewardedAd = ad
        shouldShowRewardedOnLoad = false
        ad.load()
    }

    func showRewarded(
        placementId: String = GDTAdConfig.PlacementId.rewarded,
        from rootViewController: UIViewController? = nil,
        completion: ((Bool) -> Void)? = nil
    ) {
        guard !placementId.isPlaceholderAdId else {
            completion?(false)
            return
        }

        rewardedCompletion = completion
        shouldShowRewardedOnLoad = true

        if let rewardedAd, rewardedAd.isAdValid, let rootViewController = rootViewController ?? UIApplication.shared.gdtTopViewController() {
            rewardedAd.show(fromRootViewController: rootViewController)
            shouldShowRewardedOnLoad = false
            return
        }

        let ad = GDTRewardVideoAd(placementId: placementId)
        ad.delegate = self
        rewardedAd = ad
        ad.load()
    }
}

extension GDTAdService: @preconcurrency GDTSplashAdDelegate {
    func splashAdClosed(_ splashAd: GDTSplashAd) {
        self.splashAd = nil
        splashWindow = nil
        splashBottomView = nil
    }

    func splashAdFail(toPresent splashAd: GDTSplashAd, withError error: Error) {
        print("GDT splash failed: \(error)")
        self.splashAd = nil
        splashWindow = nil
        splashBottomView = nil
    }

    func splashAdDidLoad(_ splashAd: GDTSplashAd) {
        guard let window = splashWindow ?? UIApplication.shared.gdtActiveKeyWindow, splashAd.isAdValid() else { return }
        splashAd.show(in: window, withBottomView: splashBottomView ?? UIView(frame: .zero), skip: UIView(frame: .zero))
    }
}

extension GDTAdService: @preconcurrency GDTUnifiedInterstitialAdDelegate {
    func unifiedInterstitialRenderSuccess(_ unifiedInterstitial: GDTUnifiedInterstitialAd) {
        guard let rootViewController = UIApplication.shared.gdtTopViewController(), unifiedInterstitial.isAdValid else { return }
        unifiedInterstitial.present(fromRootViewController: rootViewController)
    }

    func unifiedInterstitialFail(toLoad unifiedInterstitial: GDTUnifiedInterstitialAd, error: Error) {
        print("GDT interstitial load failed: \(error)")
        interstitialAd = nil
    }

    func unifiedInterstitialDidDismissScreen(_ unifiedInterstitial: GDTUnifiedInterstitialAd) {
        interstitialAd = nil
    }
}

extension GDTAdService: @preconcurrency GDTRewardedVideoAdDelegate {
    func gdt_rewardVideoAdDidLoad(_ rewardedVideoAd: GDTRewardVideoAd) {
        guard let rootViewController = UIApplication.shared.gdtTopViewController(), rewardedVideoAd.isAdValid else { return }
        guard shouldShowRewardedOnLoad else { return }
        rewardedVideoAd.show(fromRootViewController: rootViewController)
        shouldShowRewardedOnLoad = false
    }

    func gdt_rewardVideoAd(_ rewardedVideoAd: GDTRewardVideoAd, didFailWithError error: Error) {
        print("GDT rewarded failed: \(error)")
        rewardedCompletion?(false)
        rewardedCompletion = nil
        shouldShowRewardedOnLoad = false
        rewardedAd = nil
    }

    func gdt_rewardVideoAdDidRewardEffective(_ rewardedVideoAd: GDTRewardVideoAd, info: [AnyHashable: Any]) {
        rewardedCompletion?(true)
        rewardedCompletion = nil
        shouldShowRewardedOnLoad = false
    }

    func gdt_rewardVideoAdDidClose(_ rewardedVideoAd: GDTRewardVideoAd) {
        rewardedAd = nil
        shouldShowRewardedOnLoad = false
    }
}

private extension String {
    var isPlaceholderAdId: Bool {
        isPlaceholderGDTId
    }
}
