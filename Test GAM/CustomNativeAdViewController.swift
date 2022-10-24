//
//  CustomNativeAdViewController.swift
//  Test GAM
//
//  Created by Sylvan Ash on 24/10/2022.
//  Copyright © 2022 Sylvan Ash. All rights reserved.
//

import UIKit
import GoogleMobileAds

class CustomNativeAdViewController: UIViewController {
    private var request: NativeAdRequest?
    private var adView: UIView?
    private let loadStatusLabel = UILabel()
    private let containerView = UIView()
    private lazy var positionControl = UISegmentedControl(items: positions)
    private lazy var streamControl = UISegmentedControl(items: streams)

    private let positions = [Position.accordion.display, Position.first.display, Position.second.display, Position.third.display, Position.fourth.display]
    private let streams = [Stream.dodgeball.rawValue, Stream.home.rawValue, Stream.horse.rawValue, Stream.underwaterbasket.rawValue]

    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBar()
        setupSubviews()
        loadAd()
    }
}

private extension CustomNativeAdViewController {
    func setupNavigationBar() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .refresh, target: self, action: #selector(refreshAd))
    }

    @objc func refreshAd() {
        if let request = request, request.adLoader.isLoading { return }
        adView?.removeFromSuperview()
        adView = nil
        loadAd()
    }

    func setupSubviews() {
        view.backgroundColor = .white
        navigationItem.title = "Custom Native Ads"

        let positionLabel = UILabel()
        positionLabel.text = "Position"
        positionLabel.textColor = .black

        let streamLabel = UILabel()
        streamLabel.text = "Stream"
        streamLabel.textColor = .black

        [positionControl, streamControl].forEach { segment in
            //segment.tintColor = .orange
            segment.backgroundColor = .systemBlue
            segment.selectedSegmentTintColor = .systemPink
            segment.selectedSegmentIndex = 0
        }

        let stackview = UIStackView(arrangedSubviews: [positionLabel, positionControl, streamLabel, streamControl])
        stackview.axis = .vertical
        stackview.spacing = 8
        view.addSubview(stackview)
        stackview.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            stackview.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            stackview.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 10),
            stackview.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -10),
        ])

        view.addSubview(loadStatusLabel)
        view.addSubview(containerView)

        loadStatusLabel.text = ""
        loadStatusLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            loadStatusLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            loadStatusLabel.bottomAnchor.constraint(equalTo: containerView.topAnchor),
        ])

        containerView.backgroundColor = .systemBlue
        containerView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            containerView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            containerView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
        ])
    }

    func loadAd() {
        let selectedStream = streams[streamControl.selectedSegmentIndex]
        let stream = Stream(rawValue: selectedStream) ?? .dodgeball
        let adUnitId = "/8663477/BR\(stream.adUnitId)"
        let adTypes: [GADAdLoaderAdType] = [.customNative, .native]

        let imageLoaderOptions = GADNativeAdImageAdLoaderOptions()
        imageLoaderOptions.disableImageLoading = false

        let mediaLoaderOptions = GADNativeAdMediaAdLoaderOptions()
        mediaLoaderOptions.mediaAspectRatio = .landscape

        let videoOptions = GADVideoOptions()
        videoOptions.customControlsRequested = true
        videoOptions.clickToExpandRequested = false

        let adLoader = GADAdLoader(adUnitID: adUnitId, rootViewController: self, adTypes: adTypes, options: [imageLoaderOptions, mediaLoaderOptions, videoOptions])
        adLoader.delegate = self

        let position = positions[positionControl.selectedSegmentIndex]
        var params: [AnyHashable: Any] = [
            "app": "true",
            "pos": "nat_lar_\(position)",
            "pg": stream.pg,
        ]
        if let tags = stream.tags {
            params["tags"] = tags
        }

        let extras = GADExtras()
        extras.additionalParameters = params

        let request = GAMRequest()
        request.register(extras)

        loadStatusLabel.text = "Ad Status: Loading ♻️"
        self.request = NativeAdRequest(position: position, adLoader: adLoader)
        adLoader.load(request)
    }
}

extension CustomNativeAdViewController: GADCustomNativeAdLoaderDelegate {
    func customNativeAdFormatIDs(for adLoader: GADAdLoader) -> [String] {
        print("💚 we want info - pos: \(String(describing: request?.position))")
        if request?.position == Position.accordion.display {
            return [NativeAdTemplateId.accordion.rawValue]
        }

        return [
            NativeAdTemplateId.content.rawValue,
            NativeAdTemplateId.appInstall.rawValue,
            NativeAdTemplateId.video.rawValue,
            NativeAdTemplateId.carousel.rawValue
        ]
    }

    func adLoader(_ adLoader: GADAdLoader, didReceive customNativeAd: GADCustomNativeAd) {
        guard let templateId = NativeAdTemplateId(rawValue: customNativeAd.formatID) else {
            loadStatusLabel.text = "Ad Status: Can't parse loaded ad ⚠️"
            return
        }

        switch templateId {
        case .accordion:
            adView = CustomNativeAccordionAdView(ad: customNativeAd)
        default:
            // TODO
            loadStatusLabel.text = "Ad Status: Loaded but not implemented 💠"
        }

        if let adView = adView {
            containerView.addSubview(adView)
            adView.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                adView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
                adView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
                adView.topAnchor.constraint(equalTo: containerView.topAnchor),
                adView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor),
            ])
        }
    }
}

extension CustomNativeAdViewController: GADNativeAdLoaderDelegate {
    func adLoader(_ adLoader: GADAdLoader, didReceive nativeAd: GADNativeAd) {
        // TODO
        loadStatusLabel.text = "Ad Status: Loaded but not implemented 💠"
    }
}

extension CustomNativeAdViewController: GADAdLoaderDelegate {
    func adLoader(_ adLoader: GADAdLoader, didFailToReceiveAdWithError error: Error) {
        print("💚❌ error: \(error.localizedDescription)")
        loadStatusLabel.text = "Ad Status: Failed ❌"
    }
}

private enum Stream: String {
    case home
    case dodgeball
    case horse = "horse racing"
    case underwaterbasket = "uwb"

    var tags: String? {
        switch self {
        case .home: return nil
        case .horse: return "horse_racing"
        case .dodgeball: return "dodgeball"
        case .underwaterbasket: return "underwater_basket_weaving"
        }
    }

    var pg: String {
        switch self {
        case .home: return "home"
        default: return "section"
        }
    }

    var adUnitId: String {
        switch self {
        case .home: return ""
        case .horse: return "/Horse_racing/Main/Mob/horse_racing"
        case .dodgeball: return "/National/Main/Mob/dodgeball"
        case .underwaterbasket: return ""
        }
    }
}

private enum Position {
    case accordion
    case first
    case second
    case third
    case fourth

    var display: String {
        switch self {
        case .accordion: return "06"
        case .first: return "01"
        case .second: return "02"
        case .third: return "03"
        case .fourth: return "04"
        }
    }
}

private struct NativeAdRequest {
    let position: String
    let adLoader: GADAdLoader
}

private enum NativeAdTemplateId: String {
    case content = "10100197"
    case appInstall = "10099357"
    case video = "10100077"
    case carousel = "11806947"
    case devContent = "10075449"
    case devAppInstall = "10075569"
    case accordion = "11910332"
}

private class CustomNativeAccordionAdView: UIView {
    private var ad: GADCustomNativeAd?

    init?(ad: GADCustomNativeAd) {
        guard let image = ad.image(forKey: "image")?.image else {
            return nil
        }
        super.init(frame: .zero)
        setupSubviews(image)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupSubviews(_ image: UIImage) {
        let image = resizeAdImage(image)
        let imageView = UIImageView(image: image)
        addSubview(imageView)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            imageView.leadingAnchor.constraint(equalTo: leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: trailingAnchor),
            imageView.topAnchor.constraint(equalTo: topAnchor),
            imageView.bottomAnchor.constraint(equalTo: bottomAnchor),
            imageView.heightAnchor.constraint(equalToConstant: scaledMaxHeight),
        ])
    }

    private func resizeAdImage(_ image: UIImage) -> UIImage {
        var img = image
        var renderedSize = CGSize(width: scaledWidth, height: scaledMaxHeight)
        if !(image.size.equalTo(renderedSize) && image.scale == UIScreen.main.scale) {
            img = img.resized(to: renderedSize) ?? img
        }
        return img
    }

    private var nativeWidth: CGFloat {
        return ViewHelper.panelWidth * UIScreen.main.scale
    }

    private var scaledWidth: CGFloat {
        return nativeWidth / UIScreen.main.scale
    }

    private let aspectRatio: CGFloat = 1

    private var nativeMaxHeight: CGFloat {
        // use ceil to avoid leftover pixels when resizing
        return ceil(nativeWidth / aspectRatio)
    }

    private var scaledMaxHeight: CGFloat {
        return nativeMaxHeight / UIScreen.main.scale
    }
}

private extension UIImage {
    /**
     Returns a resized image using the specified size and quality.

     - parameter size: The size to use when resizing the image.
     - parameter quality: The desired quality. The default value is `CGInterpolationQuality.high`
     - returns: A resize image if one can be created. Otherwise, nil.
    */
    func resized(to size: CGSize, using quality: CGInterpolationQuality = .high) -> UIImage? {
        let rect = CGRect(x: 0, y: 0, width: size.width, height: size.height)
        guard let cgImage = cgImage else { return nil }
        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        let context =  UIGraphicsGetCurrentContext()

        context?.interpolationQuality = quality
        let transform = CGAffineTransform(a: 1, b: 0, c: 0, d: -1, tx: 0, ty: size.height)
        context?.concatenate(transform)

        context?.draw(cgImage, in: rect)
        guard let resizedCGImage = context?.makeImage() else { return nil }
        let image = UIImage(cgImage: resizedCGImage, scale: UIScreen.main.scale, orientation: imageOrientation)
        UIGraphicsEndImageContext()
        return image
    }
}

private class ViewHelper: NSObject {
    static let maxPanelWidth: CGFloat = 504

    static var isNarrowPhone: Bool {
        return windowWidth < 375
    }

    // Only use this if you're going to re-check the value on every appWillChangeSize call
    static var panelWidth: CGFloat {
        return min(windowWidth, maxPanelWidth)
    }

    // Only use this if you're going to re-check the value on every appWillChangeSize call
    static var panelPadding: CGFloat {
        return panelWidth >= windowWidth ? 0 : ((windowWidth - maxPanelWidth) / 2)
    }

    static var windowWidth: CGFloat {
        return UIScreen.main.bounds.width
    }

    static var windowHeight: CGFloat {
        return UIScreen.main.bounds.height
    }
}
