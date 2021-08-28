//
//  ViewController.swift
//  Test GAM
//
//  Created by Sylvan Ash on 16/11/2020.
//  Copyright © 2020 Sylvan Ash. All rights reserved.
//

import UIKit
import GoogleMobileAds

enum AdSize {
    case fluid, fixed
}

private enum Params {
    case horse
    case dodgeball

    var tags: String {
        switch self {
        case .horse: return "horse_racing"
        case .dodgeball: return "dodgeball"
        }
    }
    var adUnitId: String {
        switch self {
        case .horse: return "/Horse_racing/Main/Mob/horse_racing"
        case .dodgeball: return "/National/Main/Mob/dodgeball"
        }
    }
}

enum BannerType {
    case one
    case two
    case fluid
    case loadScreen

    var tags: String {
        switch self {
        case .one: return "dodgeball"
        case .two: return "horse_racing"
        case .fluid: return type.tags
        case .loadScreen: return "load_screen"
        }
    }
    var adUnitId: String {
        switch self {
        case .one: return type.adUnitId
        case .two: return type.adUnitId
        case .fluid: return type.adUnitId
        case .loadScreen: return "/Load_Screen"
        }
    }
    var position: String {
        switch self {
        case .one, .two: return "nat_lar_05_mob"
        case .fluid: return "nat_lar_01_mob"
        case .loadScreen: return "bnr_atf_06_mob"
        }
    }
}

private let type: Params = .horse

class BannerAdViewController: UIViewController {
    private var bannerView: GAMBannerView!
    private var request: GAMRequest!
    private let adsize: AdSize = .fluid
    private let loadStatusLabel = UILabel()
    private let containerView = UIView()
    private var bannerHeight: CGFloat = 0
    private let type: BannerType

    init(celtraType: BannerType) {
        type = celtraType
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBar()
        setupSubviews()
        setupRequest()
    }
}

private extension BannerAdViewController {
    func setupSubviews() {
        view.backgroundColor = .white

        loadStatusLabel.text = ""
        loadStatusLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(loadStatusLabel)
        NSLayoutConstraint.activate([
            loadStatusLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            loadStatusLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor),
        ])

        containerView.backgroundColor = .orange
        containerView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(containerView)
        NSLayoutConstraint.activate([
            containerView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            containerView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
        ])

        setupBannerView()
    }

    func setupBannerView() {
        let size: GADAdSize
        switch adsize {
        case .fluid:
            size = kGADAdSizeFluid
        case .fixed:
            let frame = CGRect(x: 0, y: 0, width: 300, height: 250)
            size = GADAdSizeFromCGSize(frame.size)
        }

        bannerView = GAMBannerView(adSize: size)
        bannerView.adUnitID = "/8663477/BR\(type.adUnitId)"
        bannerView.rootViewController = self
        bannerView.delegate = self
        bannerView.adSizeDelegate = self
        bannerView.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(bannerView)

        switch adsize {
        case .fluid:
            NSLayoutConstraint.activate([
                bannerView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
                bannerView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
                bannerView.topAnchor.constraint(equalTo: containerView.topAnchor),
                bannerView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor),
            ])
        case .fixed:
            NSLayoutConstraint.activate([
                bannerView.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
                bannerView.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            ])
        }
    }

    func setupRequest() {
        request = GAMRequest()

        let additionalParams: [String: Any] = [
            "pos": type.position,
            "tags": type.tags,
            "pg": "main",
            "app": "true",
        ]
        let extras = GADExtras()
        extras.additionalParameters = additionalParams
        request.register(extras)

        loadStatusLabel.text =  "Ad Status: Loading.."
        bannerView.load(request)
    }

    func setupNavigationBar() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .refresh, target: self, action: #selector(refreshAd))
    }

    @objc func refreshAd() {
        bannerView.removeFromSuperview()
        setupBannerView()
        setupRequest()
    }
}

extension BannerAdViewController: GADBannerViewDelegate {
    func bannerViewDidReceiveAd(_ bannerView: GADBannerView) {
        bannerView.isHidden = false
        loadStatusLabel.text = "Ad Status: Loaded"
    }

    func bannerView(_ bannerView: GADBannerView, didFailToReceiveAdWithError error: Error) {
        print("💚❌ error: \(error.localizedDescription)")
        loadStatusLabel.text = "Ad Status: Failed"
    }
}

extension BannerAdViewController: GADAdSizeDelegate {
    func adView(_ bannerView: GADBannerView, willChangeAdSizeTo size: GADAdSize) {
        // this is called first when the banner view is received and Google calculates it's height
        // then adViewDidReceiveAd(_:) is called
        print("💚☯️ Banner: \(bannerView.frame) | New Size: \(size.size) | Old Height: \(bannerHeight)")
        bannerHeight = max(bannerHeight, bannerView.frame.height, size.size.height)
        print("💚Ⓜ️ height: \(bannerHeight)")
    }
}
