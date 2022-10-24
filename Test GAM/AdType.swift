//
//  AdType.swift
//  Test GAM
//
//  Created by Sylvan Ash on 16/11/2020.
//  Copyright © 2020 Sylvan Ash. All rights reserved.
//

import UIKit

enum AdType: Int {
    case banner
    case rectangle
    case celtra1
    case celtra2
    case nativeStyle
    case loadScreen
    case customNative

    var description: String {
        switch self {
        case .banner: return "Banner Ad"
        case .rectangle: return "Rectangle Ad"
        case .celtra1: return "Celtra A: Dodgeball Stream"
        case .celtra2: return "Celtra B: Horse Racing"
        case .nativeStyle: return "Google Styled Native"
        case .loadScreen: return "Load Screen Banner Ad"
        case .customNative: return "Custom Native Ad"
        }
    }

    var adUnitId: String {
        switch self {
        case .banner, .nativeStyle, .loadScreen: return "8c6814b7e08345e2a39ee522a774b2e5"
        case .rectangle: return "d394eaf7019246778d7d03f991de16fd"
        case .celtra1: return "865119d3b09c4875b6d81da8c7873d4b"
        case .celtra2: return "865119d3b09c4875b6d81da8c7873d4b"
        case .customNative: return "865119d3b09c4875b6d81da8c7873d4b"
        }
    }

    var size: CGSize {
        switch self {
        case .banner: return CGSize(width: 320, height: 50)
        case .rectangle: return CGSize(width: 300, height: 250)
        case .celtra1, .celtra2, .nativeStyle, .loadScreen, .customNative: return .zero
        }
    }

    var sizeString: String {
        switch self {
        case .banner: return "320x50"
        case .rectangle: return "300x250"
        case .celtra1, .celtra2, .nativeStyle, .loadScreen, .customNative: return "0x0"
        }
    }
}

extension AdType {
    static func generateSequentialCases() -> [AdType] {
        var cases = [AdType]()
        var count = 0
        while let validCase = AdType(rawValue: count) {
            cases.append(validCase)
            count += 1
        }
        return cases
    }
}
