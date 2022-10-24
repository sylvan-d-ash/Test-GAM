//
//  AppDelegate.swift
//  Test GAM
//
//  Created by Sylvan Ash on 16/11/2020.
//  Copyright © 2020 Sylvan Ash. All rights reserved.
//

import UIKit
import OMSDK_Bleacherreport
import GoogleMobileAds

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        initializeOMSDK()
        GADMobileAds.sharedInstance().requestConfiguration.testDeviceIdentifiers = [ kGADSimulatorID ]
        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }
}

extension AppDelegate {
    func initializeOMSDK() {
        if OMIDBleacherreportSDK.shared.isActive { return }
        OMIDBleacherreportSDK.shared.activate()
    }
}
