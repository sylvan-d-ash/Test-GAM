//import Foundation
//import GoogleMobileAds
//import AdSupport
//
//struct AdContentURLBuilder {
//    private let adViewData: AdViewData
//    //private let baseContentUrl = BRDomains.url(for: .web).absoluteString
//
//    init(adViewData: AdViewData) {
//        self.adViewData = adViewData
//    }
//
//    func contentURL() -> String? {
//        return contentURL(forData: adViewData)
//    }
//}
//
//private extension AdContentURLBuilder {
//    func contentURL(forData adViewData: AdViewData) -> String? {
//        switch adViewData.location {
//        case .homeStream, .gamecastStream:
//            return "baseContentUrl"
//        case .stream:
//            if let tag = adViewData.tags?.first {
//                return contentURL(forTeamTag: tag)
//            } else {
//                return nil
//            }
//        case .addFantasyPlayersiPhone:
//            if let tag = adViewData.tags?.first {
//                return contentURL(forFantasyPlayersTeamTag: tag)
//            } else {
//                return nil
//            }
//        case .scoresTray:
//            return "site:www.bleacherreport.com scores"
//        case .alertCard, .streamSponsored, .amaSponsored, .alertsTab, .streamStandings, .streamSchedule:
//            return nil
//        }
//    }
//
//    func contentURL(forTeamTag teamTag: String) -> String? {
//        if FantasyManager.isFantasySport(teamTag) {
//            return contentURL(forFantasyPlayersTeamTag: teamTag)
//        } else {
//            switch teamTag {
//            case UniqueName.starredArticles:
//                return contentURL(forContextualMatch: "articles")
//            case STREAM_AGGREGATE_LEAD_WRITERS:
//                return contentURL(forContextualMatch: "writers")
//            case STREAM_AGGREGATE_MY_OLYMPICS:
//                return contentURL(forBasicTeamTag: "olympics")
//            default:
//                return contentURL(forBasicTeamTag: teamTag)
//            }
//        }
//    }
//
//    func contentURL(forContextualMatch string: String) -> String {
//        return "site:bleacherreport.com \(string)"
//    }
//
//    func contentURL(forBasicTeamTag teamTag: String) -> String {
//        return "\(baseContentUrl)/\(teamTag)"
//    }
//
//    func contentURL(forFantasyPlayersTeamTag teamTag: String) -> String? {
//        let relatedTeamTag: String?
//        switch teamTag {
//        case FANTASY_FOOTBALL_UNIQUE_NAME:
//            relatedTeamTag = STREAM_FANTASY_FOOTBALL_NEWS
//        case FANTASY_BASKETBALL_UNIQUE_NAME:
//            relatedTeamTag = STREAM_FANTASY_BASKETBALL_NEWS
//        case FANTASY_BASEBALL_UNIQUE_NAME:
//            relatedTeamTag = STREAM_FANTASY_BASEBALL_NEWS
//        case FANTASY_SOCCER_UNIQUE_NAME:
//            relatedTeamTag = STREAM_WORLD_FOOTBALL
//        default:
//            relatedTeamTag = nil
//        }
//
//        return relatedTeamTag.flatMap( { contentURL(forBasicTeamTag: $0) } )
//    }
//}
//
//
//enum AdViewLocation {
//    case homeStream
//    case gamecastStream
//    case stream
//    case addFantasyPlayersiPhone
//    case scoresTray
//    case alertCard // Fluid ad that can appear at the bottom of the alert card
//    case streamSponsored // Fluid ad that can appear after an article you scrolled to via alert/notification
//    case amaSponsored // Fluid ad that can appear just below the comment sorting controls on an AMA track
//    case alertsTab // Banner ad that can appear in Alerts tab
//    case streamStandings // Banner ad that can appear in Standings page for a Stream
//    case streamSchedule // Banner ad that can appear in Schedules page for a Stream
//}
//
//struct AdViewData {
//    let location: AdViewLocation
//    let adSize: GADAdSize
//    let controller: UIViewController
//    let pos: String
//    let validSizes: [CGSize]?
//    let parameters: [String: Any]?
//    let tags: [String]?
//    let fanAlert: Bool
//    let site: String?
//    let articleId: String?
//    var contentURL: String? { return AdContentURLBuilder(adViewData: self).contentURL() }
//    var adUnitId: String { return AdUnitIdBuilder.adUnitIdForData(self) }
//
//    init(location: AdViewLocation, frame: CGRect, controller: UIViewController, pos: String, validSizes: [CGSize]?, parameters: [String: Any]?, tags: [String]?, fanAlert: Bool = false, site: String?, articleId: String?) {
//        self.init(location: location, size: GADAdSizeFromCGSize(frame.size), controller: controller, pos: pos, validSizes: validSizes, parameters: parameters, tags: tags, fanAlert: fanAlert, site: site, articleId: articleId)
//    }
//
//    init(location: AdViewLocation, size: GADAdSize, controller: UIViewController, pos: String, validSizes: [CGSize]?, parameters: [String: Any]?, tags: [String]?, fanAlert: Bool = false, site: String?, articleId: String?) {
//        self.location = location
//        self.adSize = size
//        self.controller = controller
//        self.pos = pos
//        self.validSizes = validSizes
//        self.parameters = parameters
//        self.tags = tags
//        self.fanAlert = fanAlert
//        self.site = site
//        self.articleId = articleId
//    }
//}
//
//enum AdPosition: String {
//    case accordion = "nat_lar_06"
//    case logoAd = "nat_lar_05"
//}
//
//
//enum AdConstants {
//    enum Sites {
//        static let gamecast = "gamecast"
//        static let topGames = "top_games"
//    }
//}
//
//protocol HasAdView {
//    func adView(withFrame frame: CGRect, pos: String, validSizes: [CGSize], parameters: [String : Any]?) -> AdView?
//    func sponsoredArticleAdView(withFrame frame: CGRect, pos: String, parameters: [String : Any]?) -> AdView?
//}
//
//@objc protocol AdViewDelegate: class {
//    func adViewDidReceiveAd(_ bannerView: GADBannerView)
//    func adView(_ bannerView: GADBannerView, didFailToReceiveAdWithError error: GADRequestError)
//}
//
//class AdView: DFPBannerView {
//
//    @objc enum AdIdStringOverride: Int {
//        case uninitialized
//        case none
//        case sim
//    }
//
//    var request: DFPRequest
//    private var initialParameters: [String: Any]?
//    var totalParameters: [String: Any]?
//    private static var customAdParams: [String: Any]?
//    private static var previousCustomParams: [String: Any]?
//    weak var adViewDelegate: AdViewDelegate?
//    private var moatTracker: TRNMoatWebTracker?
//
//    private static var shouldOverrideAdIdString: AdIdStringOverride = .uninitialized
//
//    init?(adViewData: AdViewData) {
//
//        #if DEMO
//        return nil
//        #endif
//
//        if TeamStreamApp.blockAdsForScreenshots() {
//            return nil
//        }
//
//        self.request = DFPRequest()
//        super.init(adSize: adViewData.adSize, origin: CGPoint.zero)
//
//        self.frame = CGRect(x: 0, y: 0, width: adViewData.adSize.size.width, height: adViewData.adSize.size.height)
//
//        self.delegate = self
//        if adViewData.controller.navigationController == nil {
//            self.rootViewController = adViewData.controller
//        } else {
//            self.rootViewController = adViewData.controller.navigationController
//        }
//        self.backgroundColor = .black
//
//        self.adUnitID = adViewData.adUnitId
//
//        if let contentUrl = adViewData.contentURL, !contentUrl.isEmpty {
//            self.request.contentURL = contentUrl
//        }
//
//        var additionalParams = AdParametersBuilder.displayAdParameters(for: adViewData, frame: frame)
//
//        if let parameters = adViewData.parameters {
//            additionalParams.merge(parameters, favoring: .existing)
//        }
//
//        initialParameters = additionalParams
//
//        if let customAdParams = AdView.customAdParams {
//            additionalParams.merge(customAdParams, favoring: .existing)
//        }
//
//        let extras = GADExtras()
//        extras.additionalParameters = additionalParams
//        self.request.register(extras)
//        self.totalParameters = additionalParams
//
//        if !adViewData.validSizes.isEmpty {
//            self.adSizeDelegate = self
//            self.validAdSizes = adViewData.validSizes?.compactMap({ NSValue(cgSize: $0) })
//        }
//
//        NotificationCenter.default.addObserver(self, selector: #selector(updateAdParamsAndReload), name: NSNotification.Name(rawValue: NOTIFICATION_AD_PARAMS), object: nil)
//
//        self.accessibilityIgnoresInvertColors = true
//
//        loadRequest()
//        self.backgroundColor = .clear
//
//        if adViewData.location == .addFantasyPlayersiPhone, ViewHelper.panelWidth == 320 {
//            addDropShadow()
//        }
//
//    }
//
//    required init?(coder aDecoder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
//
//    deinit {
//        self.adSizeDelegate = nil
//        self.cleanUp()
//    }
//
//    @objc func updateAdParamsAndReload() {
//        var newParams = [String: String]()
//        if let initialParams = initialParameters as? [String: String] {
//            newParams.merge(initialParams, favoring: .existing)
//        }
//
//        if let customParams = AdView.customAdParams as? [String: String] {
//            newParams.merge(customParams, favoring: .existing)
//        }
//
//        resetAdMobExtras(to: newParams)
//        loadRequest()
//    }
//
//    class func shouldOverrideIdStringForSim() -> Bool {
//        return AdView.shouldOverrideIdString() == .sim
//    }
//
//    class func shouldOverrideIdString() -> AdIdStringOverride {
//        switch shouldOverrideAdIdString {
//        case .uninitialized:
//            initializeAdIdStringOverride()
//        default: ()
//        }
//        return shouldOverrideAdIdString
//    }
//}
//
//private extension AdView {
//    func shouldAutoRefresh(forData adViewData: AdViewData) -> Bool {
//        return true
//    }
//
//    func loadRequest() {
//        guard let adUnitID = self.adUnitID else { return }
//
//        TSLog(adUnitID)
//        load(request)
//    }
//
//    class func initializeAdIdStringOverride() {
//        setShouldOverrideIdString(newOverride: .none)
//    }
//
//    func addDropShadow() {
//        let shadowPath = CGRect(x: self.layer.bounds.origin.x - 10, y: self.layer.bounds.origin.y + 2, width: self.layer.bounds.size.width + 20, height: 5)
//        self.layer.shadowPath = UIBezierPath(rect: shadowPath).cgPath
//        addDropShadow(withOffset: CGSize(width: 0, height: -4), opacity: 0.4, radius: 4)
//    }
//
//    func cleanUp() {
//        stopMoat()
//        NotificationCenter.default.removeObserver(self)
//    }
//
//    @objc(resetAdMobExtrasTo:)
//    func resetAdMobExtras(to newParams: [String: Any]) {
//        let newExtras = GADExtras()
//        newExtras.additionalParameters = newParams
//        totalParameters = newParams
//        request.register(newExtras)
//    }
//}
//
//extension AdView {
//
//    override open weak var delegate: GADBannerViewDelegate? {
//        didSet {
//            assert(delegate === self, "Do not override AdView.delegate, use AdView.adViewDelegate instead.")
//            if delegate !== self {
//                delegate = self
//            }
//        }
//    }
//
//    class func resetCustomAdParams() {
//        self.previousCustomParams = self.customAdParams
//        self.customAdParams = [String: Any]()
//    }
//
//    @objc(setShouldOverrideIdString:)
//    class func setShouldOverrideIdString(newOverride: AdIdStringOverride) {
//        shouldOverrideAdIdString = newOverride
//    }
//
//    @objc(addCustomAdParams:)
//    class func addCustomAdParams(_ params: [AnyHashable: Any]?) {
//        if self.customAdParams == nil {
//            self.customAdParams = [String: Any]()
//        }
//
//        if let adParams = params as? [String: Any] {
//            self.customAdParams?.merge(adParams, favoring: .existing)
//        }
//
//        NotificationCenter.default.post(name: Notification.Name(rawValue: NOTIFICATION_AD_PARAMS), object: nil)
//    }
//
//    // MARK: - Misc/support
//
//    class func heightForFluidAd(withBaseSize baseSize: CGSize, actualWidth width: CGFloat) -> CGFloat {
//        return ((baseSize.height / baseSize.width) * width).roundedDownForDeviceScreen()
//    }
//}
//
//extension AdView: GADAdSizeDelegate {
//
//    public func adView(_ bannerView: GADBannerView, willChangeAdSizeTo size: GADAdSize) {
//        TSLog("GAD will change ad size to: \(NSCoder.string(for: size.size))")
//    }
//}
//
//// MARK: - Moat
//extension AdView {
//    public func trackMoat() {
//        stopMoat()
//        if PrivacyManager.sharedConsentManager().shouldEnableDataVendor(dataVendor: .moat) && window != nil {
//            moatTracker = TRNMoatWebTracker(webComponent: self)
//            moatTracker?.startTracking()
//        }
//    }
//
//    fileprivate func stopMoat() {
//        if let tracker = moatTracker {
//            tracker.stopTracking()
//            moatTracker = nil
//        }
//    }
//}
//
//extension AdView: GADBannerViewDelegate {
//    public func adViewDidReceiveAd(_ bannerView: GADBannerView) {
//        trackMoat()
//        adViewDelegate?.adViewDidReceiveAd(bannerView)
//    }
//
//    public func adView(_ bannerView: GADBannerView, didFailToReceiveAdWithError error: GADRequestError) {
//        adViewDelegate?.adView(bannerView, didFailToReceiveAdWithError: error)
//    }
//
//    public func adViewWillPresentScreen(_ bannerView: GADBannerView) {
//        UIActivityIndicatorView.appearance().color = UIColor.brBlack80
//    }
//
//    public func adViewWillLeaveApplication(_ bannerView: GADBannerView) { }
//}
