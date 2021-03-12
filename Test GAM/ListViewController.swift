//
//  ListViewController.swift
//  Test GAM
//
//  Created by Sylvan Ash on 16/11/2020.
//  Copyright © 2020 Sylvan Ash. All rights reserved.
//

import UIKit

class ListViewController: UIViewController {
    private let tableView = UITableView(frame: .zero, style: .plain)
    private var ads: [AdType] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        setupSubviews()
        setupNavigationBar()
        loadData()
    }
}

private extension ListViewController {
    func setupSubviews() {
        view.backgroundColor = .white

        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "\(UITableViewCell.self)")
        tableView.tableFooterView = UIView()
        tableView.separatorInset = UIEdgeInsets()
        tableView.dataSource = self
        tableView.delegate = self
        tableView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(tableView)

        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
        ])
    }

    func setupNavigationBar() {
        navigationItem.title = "Types of Ads"
    }

    func loadData() {
        ads = AdType.generateSequentialCases()
    }
}

extension ListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return ads.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "\(UITableViewCell.self)", for: indexPath)
        cell.textLabel?.text = "\(ads[indexPath.row].description)"
        return cell
    }
}

extension ListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        defer { tableView.deselectRow(at: indexPath, animated: false) }

        let controller: UIViewController
        let ad = ads[indexPath.row]
        switch ad {
        case .banner:
            controller = DisplayAdViewController(adType: .banner)
        case .rectangle:
            controller = DisplayAdViewController(adType: .rectangle)
        case .celtra1:
            controller = BannerAdViewController(celtraType: .one)
        case .celtra2:
            controller = BannerAdViewController(celtraType: .two)
        }
        navigationController?.pushViewController(controller, animated: true)
    }
}

