//
//  OMManager.swift
//  Test GAM
//
//  Created by Sylvan Ash on 25/10/2022.
//  Copyright © 2022 Sylvan Ash. All rights reserved.
//

import OMSDK_Bleacherreport

private enum Constants {
    static let vendorKey = "iabtechlab.com-omid"
    static let verificationScriptURL = "https://s3-us-west-2.amazonaws.com/omsdk-files/compliance-js/omid-validation-verification-script-v1.js"
    static let verificationScriptURL2 = "https://s3-us-west-2.amazonaws.com/omsdk-files/compliance-js/"
    static let verificationParameters = "iabtechlab-Bleacherreport"
}

class OMManager {
    static let shared = OMManager()
    private init() {}

    var omidJSService: String?

    func activateOMSDK() {
        if OMIDBleacherreportSDK.shared.isActive { return }
        OMIDBleacherreportSDK.shared.activate()
        fetchOMIDJSLibrary()
    }

    func fetchOMIDJSLibrary() {
        guard omidJSService == nil, let url = URL(string: Constants.verificationScriptURL) else { return }
        URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            if let data = data, let omidJS = String(data: data, encoding: .utf8) {
                print("OM - js service: \(omidJS)")
                self?.omidJSService = omidJS
            }
            if let error = error {
                print("OM - error: \(error.localizedDescription)")
            }
        }.resume()
    }
}

protocol UsesOMTracking: AnyObject {
    var session: OMIDBleacherreportAdSession? { get set }
    func addMainAdView(to session: OMIDBleacherreportAdSession) -> Bool
    func adLoaded(with adEvents: OMIDBleacherreportAdEvents?)
}

extension UsesOMTracking {
    var omidPartner: OMIDBleacherreportPartner? {
        guard let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String else { return nil }
        return OMIDBleacherreportPartner(name: "Bleacherreport", versionString: version)
    }

    func startMeasurement() {
        guard let session = createAdSession() else { return }
        _ = addMainAdView(to: session)

        let adEvents: OMIDBleacherreportAdEvents?
        do {
            adEvents = try OMIDBleacherreportAdEvents(adSession: session)
        } catch {
            print("OM - unable to instantiate ad events: \(error.localizedDescription)")
            return
        }

        print("OM - starting measurement session ♻️")

        session.start()
        self.session = session

        // fire loaded events
        adLoaded(with: adEvents)

        // record omid native impression
        if session.configuration.impressionOwner == .nativeOwner {
            do {
                try adEvents?.impressionOccurred()
            } catch {
                print("OM - error recording impression: \(error.localizedDescription)")
            }
        }
    }

    private func createAdSession() -> OMIDBleacherreportAdSession? {
        guard let context = nativeAdSessionContext(), let config = imageAdSessionConfiguration() else { return nil }
        do {
            return try OMIDBleacherreportAdSession(configuration: config, adSessionContext: context)
        } catch {
            print("OM - error creating session: \(error.localizedDescription)")
            return nil
        }
    }

    private func imageAdSessionConfiguration() -> OMIDBleacherreportAdSessionConfiguration? {
        do {
            return try OMIDBleacherreportAdSessionConfiguration(creativeType: .nativeDisplay, impressionType: .onePixel, impressionOwner: .nativeOwner, mediaEventsOwner: .noneOwner, isolateVerificationScripts: true)
        } catch {
            print("OM - error creating session configuration: \(error.localizedDescription)")
            return nil
        }
    }

    private func createVerificationScriptResource() -> OMIDBleacherreportVerificationScriptResource? {
        guard let url = URL(string: Constants.verificationScriptURL) else { return nil }
        return OMIDBleacherreportVerificationScriptResource(url: url, vendorKey: Constants.vendorKey, parameters: Constants.verificationParameters)
    }

    private func nativeAdSessionContext() -> OMIDBleacherreportAdSessionContext? {
        guard let partner = omidPartner,
              let omidJSService = OMManager.shared.omidJSService,
              let verificationResource = createVerificationScriptResource() else { return nil }
        do {
            return try OMIDBleacherreportAdSessionContext(partner: partner,
                                                          script: omidJSService,
                                                          resources: [verificationResource],
                                                          contentUrl: nil,
                                                          customReferenceIdentifier: nil)
        } catch {
            print("OM - error creating session context: \(error.localizedDescription)")
            return nil
        }
    }
}
