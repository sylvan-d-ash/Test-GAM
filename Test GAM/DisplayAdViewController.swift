//
//  DisplayAdViewController.swift
//  Test GAM
//
//  Created by Sylvan Ash on 16/11/2020.
//  Copyright © 2020 Sylvan Ash. All rights reserved.
//

import GoogleMobileAds
import UIKit

class DisplayAdViewController: UIViewController {
    private let adType: AdType
    private let adUnitId = "/8663477/BR/Horse_Racing/main/mob/horse-racing"
    private lazy var params: [String: Any] = {
        let dict: [String: Any] = [
            "tdcidx": "ckJzckJzckJuckJzcl9zckJzb0JzckJuckJzckJzckJzckJz",
            "locale": "en_US",
            "vers": "7.22.0",
            "app": "true",
            "pg": "main",
            "build": "8615",
            "size": adType.sizeString,
            "sid": "1",
            "page": "main",
            "pos": "bnr_atf_01_mob",
            "tags": "dodgeball",
            "tag_id": "2474",
            "site": "Dodgeball",
            "division": "none",
            "team": "none",
            "alert": "false",
        ]
        return dict
    }()

    private let adTypeLabel = UILabel()
    private let containerView = UIView()
    private var bannerView: GAMBannerView!
    private let loadStatusLabel = UILabel()

    init(adType: AdType) {
        self.adType = adType
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupSubviews()
        setupNavigationBar()
    }
}

private extension DisplayAdViewController {
    func setupSubviews() {
        view.backgroundColor = .white

        adTypeLabel.text = adType.description
        adTypeLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(adTypeLabel)
        NSLayoutConstraint.activate([
            adTypeLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            adTypeLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
        ])

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
            containerView.topAnchor.constraint(equalTo: adTypeLabel.bottomAnchor, constant: 20),
        ])

        setupAdView()
    }

    func setupAdView() {
        let size = GADAdSizeFromCGSize(adType.size)
        bannerView = GAMBannerView(adSize: size)
        bannerView.adUnitID = adUnitId
        bannerView.rootViewController = self
        bannerView.delegate = self
        bannerView.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(bannerView)

        NSLayoutConstraint.activate([
            bannerView.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            bannerView.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            containerView.heightAnchor.constraint(equalToConstant: 300),
        ])

        let request = GAMRequest()
        let extras = GADExtras()
        extras.additionalParameters = params
        request.register(extras)

        loadStatusLabel.text = "Loading.."
        bannerView.load(request)
    }

    func setupNavigationBar() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .refresh, target: self, action: #selector(refreshAd))
    }

    @objc func refreshAd() {
        bannerView.removeFromSuperview()
        setupAdView()
    }
}

extension DisplayAdViewController: GADBannerViewDelegate {
    public func bannerViewDidReceiveAd(_ bannerView: GADBannerView) {
        bannerView.isHidden = false
        loadStatusLabel.text = "Ad Status: Loaded"
    }

    public  func bannerView(_ bannerView: GADBannerView, didFailToReceiveAdWithError error: Error) {
        print("💚❌ error: \(error.localizedDescription)")
        loadStatusLabel.text = "Ad Status: Failed"
    }
}

extension UIView {
    func pinToTop() {
        guard let superview = superview else { return }
        translatesAutoresizingMaskIntoConstraints = false
        topAnchor.constraint(equalTo: superview.topAnchor).isActive = true
    }

    func pinToBottom() {
        guard let superview = superview else { return }
        translatesAutoresizingMaskIntoConstraints = false
        bottomAnchor.constraint(equalTo: superview.bottomAnchor).isActive = true
    }

    func pinToLeft() {
        guard let superview = superview else { return }
        translatesAutoresizingMaskIntoConstraints = false
        leadingAnchor.constraint(equalTo: superview.leadingAnchor).isActive = true
    }

    func pinToRight() {
        guard let superview = superview else { return }
        translatesAutoresizingMaskIntoConstraints = false
        trailingAnchor.constraint(equalTo: superview.trailingAnchor).isActive = true
    }

    func fillParent() {
        pinToTop()
        pinToBottom()
        pinToLeft()
        pinToRight()
    }
}
