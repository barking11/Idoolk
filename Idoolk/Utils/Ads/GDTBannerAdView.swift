import GDTMobSDK
import SwiftUI
import UIKit

struct GDTBannerAdView: UIViewRepresentable {
    var placementId: String = GDTAdConfig.PlacementId.banner
    var height: CGFloat = GDTAdConfig.Layout.bannerHeight
    var autoSwitchInterval: Int = 30

    func makeCoordinator() -> Coordinator {
        Coordinator()
    }

    func makeUIView(context: Context) -> UIView {
        let containerView = UIView()
        containerView.backgroundColor = .clear

        guard !placementId.isPlaceholderGDTId,
              let rootViewController = UIApplication.shared.gdtTopViewController() else {
            return containerView
        }

        let bannerView = GDTUnifiedBannerView(
            frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: height),
            placementId: placementId,
            viewController: rootViewController
        )
        bannerView.delegate = context.coordinator
        bannerView.autoSwitchInterval = Int32(autoSwitchInterval)
        bannerView.translatesAutoresizingMaskIntoConstraints = false

        containerView.addSubview(bannerView)
        NSLayoutConstraint.activate([
            bannerView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            bannerView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            bannerView.topAnchor.constraint(equalTo: containerView.topAnchor),
            bannerView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor)
        ])

        context.coordinator.bannerView = bannerView
        bannerView.loadAdAndShow()

        return containerView
    }

    func updateUIView(_ uiView: UIView, context: Context) {}

    final class Coordinator: NSObject, GDTUnifiedBannerViewDelegate {
        var bannerView: GDTUnifiedBannerView?

        func unifiedBannerViewFailed(toLoad unifiedBannerView: GDTUnifiedBannerView, error: Error) {
            print("GDT banner load failed: \(error)")
        }

        func unifiedBannerViewWillClose(_ unifiedBannerView: GDTUnifiedBannerView) {
            unifiedBannerView.removeFromSuperview()
        }
    }
}

extension View {
    func gdtBannerAd(
        placementId: String = GDTAdConfig.PlacementId.banner,
        height: CGFloat = GDTAdConfig.Layout.bannerHeight
    ) -> some View {
        GDTBannerAdView(placementId: placementId, height: height)
            .frame(height: height)
    }
}
