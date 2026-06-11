import GDTMobSDK
import SwiftUI
import UIKit

struct GDTNativeExpressAdContainerView: UIViewRepresentable {
    var placementId: String = GDTAdConfig.PlacementId.native
    var size: CGSize

    init(
        placementId: String = GDTAdConfig.PlacementId.native,
        width: CGFloat = UIScreen.main.bounds.width - 32,
        height: CGFloat = GDTAdConfig.Layout.nativeHeight
    ) {
        self.placementId = placementId
        self.size = CGSize(width: width, height: height)
    }

    func makeUIView(context: Context) -> NativeExpressContainerView {
        let view = NativeExpressContainerView()
        view.load(placementId: placementId, size: size)
        return view
    }

    func updateUIView(_ uiView: NativeExpressContainerView, context: Context) {}
}

final class NativeExpressContainerView: UIView, GDTNativeExpressAdDelegete {
    private var nativeExpressAd: GDTNativeExpressAd?
    private var expressAdView: GDTNativeExpressAdView?

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .clear
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        backgroundColor = .clear
    }

    func load(placementId: String, size: CGSize) {
        guard !placementId.isPlaceholderGDTId else { return }

        guard let nativeExpressAd = GDTNativeExpressAd(placementId: placementId, adSize: size) else { return }
        nativeExpressAd.delegate = self
        nativeExpressAd.videoMuted = true
        self.nativeExpressAd = nativeExpressAd
        nativeExpressAd.load(1)
    }

    func nativeExpressAdSuccess(toLoad nativeExpressAd: GDTNativeExpressAd, views: [GDTNativeExpressAdView]) {
        guard let adView = views.first else { return }
        adView.controller = UIApplication.shared.gdtTopViewController()
        adView.render()
        expressAdView = adView
    }

    func nativeExpressAdFail(toLoad nativeExpressAd: GDTNativeExpressAd, error: Error) {
        print("GDT native express load failed: \(error)")
    }

    func nativeExpressAdViewRenderSuccess(_ nativeExpressAdView: GDTNativeExpressAdView) {
        addExpressAdView(nativeExpressAdView)
    }

    func nativeExpressAdViewRenderFail(_ nativeExpressAdView: GDTNativeExpressAdView) {
        print("GDT native express render failed")
    }

    func nativeExpressAdViewClosed(_ nativeExpressAdView: GDTNativeExpressAdView) {
        nativeExpressAdView.removeFromSuperview()
    }

    private func addExpressAdView(_ adView: GDTNativeExpressAdView) {
        subviews.forEach { $0.removeFromSuperview() }

        adView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(adView)
        NSLayoutConstraint.activate([
            adView.leadingAnchor.constraint(equalTo: leadingAnchor),
            adView.trailingAnchor.constraint(equalTo: trailingAnchor),
            adView.topAnchor.constraint(equalTo: topAnchor),
            adView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
}

extension View {
    func gdtNativeExpressAd(
        placementId: String = GDTAdConfig.PlacementId.native,
        height: CGFloat = GDTAdConfig.Layout.nativeHeight
    ) -> some View {
        GDTNativeExpressAdContainerView(placementId: placementId, height: height)
            .frame(height: height)
    }
}
