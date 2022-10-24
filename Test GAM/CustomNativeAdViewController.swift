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
       //
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
