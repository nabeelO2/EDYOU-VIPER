//
//  AppDelegate.swift
//  EDYOU
//
//  Created by  Mac on 03/09/2021.
//

import UIKit
import IQKeyboardManagerSwift
import GoogleMaps
import Bugsnag
import UserNotifications
import UserNotificationsUI
import PushKit
import FirebaseCore
import FirebaseCrashlytics
import UXCam
import BackgroundTasks
import Combine
import TigaseLogging
import Intents


@main
class AppDelegate: UIResponder, UIApplicationDelegate{
    
    
    private let logger = Logger(subsystem: Bundle.main.bundleIdentifier!, category: "main");
    var backgroundFetchInProgress = false;
    
//    var window: UIWindow?
    var token = ""
    var providerDelegate: ProviderDelegate!
    let callManager = CallManager()
    class var shared: AppDelegate {
      return UIApplication.shared.delegate as! AppDelegate
    }
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        //Root and Basic Setup
        
        self.checkRachability()
        self.checkFirstLaunched()
        self.checkRoot()
        callManager.controllerPresentingDelay = 2
        XMPPAppDelegateManager.shared.window = Application.shared.window
        XMPPAppDelegateManager.shared.application(application, willFinishLaunchingWithOptions: launchOptions)
        //Call Manager

        //Firebase
        FirebaseApp.configure()
        GMSServices.provideAPIKey("AIzaSyDegqRdfM1PdUWN8spIF-xMz5XkQTC58FY")
        //Realm
              
        RealmContextManager.shared.prepareDefaultRealm()
    
        //Audio
        AudioPlayerManager.player.initPlayer()
        //Void
        voipRegistration()
        setIQKeyboardManager()
        Utilities.loadEmojis()
        
        //Bugsnag
//        Bugsnag.start()
        Bugsnag.start(withApiKey: "6ffb6e698622b999eba59835c3db2ae4")
       // f4566987d944ecf51d9e2cb368f7135e old key
        let configuration = UXCamConfiguration(appKey: "ayjt62ks348iv2d")

        //Example
        configuration.enableAdvancedGestureRecognition = true
        
        UXCam.optIntoSchematicRecordings()
        UXCam.start(with: configuration)
        
//        Branch.setUseTestBranchKey(true)
//         // Listener for Branch deep link data
//         Branch.getInstance().initSession(launchOptions: launchOptions) { (params, error) in
//            print(params as? [String: AnyObject] ?? {})
//             if let params = params{
//                 if let urlStr = params["~referring_link"] as? String, let url = URL(string: urlStr){
//                     self.processInviteLink(url)
//                 }
//             }
//               // Access and use deep link data here (nav to page, display content, etc.)
//         }
        
        return true
    }
    
    override init() {
        super.init()
        UIFont.overrideInitialize()
    }
    
    func checkRoot() {
        let isLoggedIn = UserDefaults.standard.bool(forKey: "loggedIn")
        if Keychain.shared.accessToken != nil && isLoggedIn == true {
            Application.shared.switchToHome()
        } else {
            XMPPAppDelegateManager.shared.logoutFromXMPP()
            Application.shared.switchToLogin()
        }
    }
    func checkFirstLaunched() {
        if AppDefaults.shared.firstLaunch {
            AppDefaults.shared.firstLaunch = true
            Keychain.shared.clear()
        }
    }
    func  isLoggedIn() -> Bool{
        let  userId = Cache.shared.user?.userID ?? ""
        return !userId.isEmpty
    }
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        return XMPPAppDelegateManager.shared.application(app,open: url,options: options)
    }



    func application(_ application: UIApplication, continue userActivity: NSUserActivity, restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void) -> Bool {
        if userActivity.activityType == NSUserActivityTypeBrowsingWeb,
           let webpageURL = userActivity.webpageURL {
                processInviteLink(webpageURL)
            return true
        }
        
        return XMPPAppDelegateManager.shared.application(application,continue:userActivity,restorationHandler: restorationHandler);
    }
    
    private func processInviteLink(_ url : URL){
        if let invitationCode = URLComponents(url: url, resolvingAgainstBaseURL: false)?.queryItems?.first(where: { $0.name == "invitationcode" })?.value {
            
            UserDefaults.standard.set(invitationCode, forKey: "invitationCode")
            print("move to signup with invite action Code \(invitationCode)")
            
//                let isLoggedIn = UserDefaults.standard.value(forKey: "loggedIn") ?? false
//                if Keychain.shared.accessToken != nil && isLoggedIn as! Bool == true {
//                    Application.shared.switchToHome()
//                } else {
//                    Application.shared.switchToSignup()
//                }
        }
        else if let verificationCode = URLComponents(url: url, resolvingAgainstBaseURL: false)?.queryItems?.first(where: { $0.name == "verificationcode" })?.value{
            
            let array = verificationCode.map({ String($0) })
        
            UserDefaults.standard.set(verificationCode, forKey: "verificationCode")
            if let vc = Application.shared.topViewController as? VerifyEmailController{
                vc.VerifyOTP(array)
            }
            else{
                Application.shared.switchToOtp(array)
            }
        }
    }
    
}

extension AppDelegate: PKPushRegistryDelegate {
    func voipRegistration() {
        // Create a push registry object
        let mainQueue = DispatchQueue.main
        let voipRegistry: PKPushRegistry = PKPushRegistry(queue: mainQueue)
        voipRegistry.delegate = self
        voipRegistry.desiredPushTypes = [PKPushType.voIP]
    }
    
    // Handle updated push credentials
    func pushRegistry(_ registry: PKPushRegistry, didUpdate credentials: PKPushCredentials, for type: PKPushType) {
        print(credentials.token)
        let deviceToken = credentials.token.map { data in String(format: "%02.2hhx", data) }.joined()
        print("pushRegistry -> deviceToken :\(deviceToken)")
        UserDefaults.standard.set(deviceToken, forKey: "voipToken")
        self.sendAPNSRegistrationCall()
    }

    func sendAPNSRegistrationCall(){
        let pushToken = UserDefaults.standard.string(forKey: "deviceToken") ??  ""
        let voipToken = UserDefaults.standard.string(forKey: "voipToken") ?? ""
        if self.isLoggedIn() == true {
            PushEventHandler.instance.pushkitDeviceId = voipToken;
            PushEventHandler.instance.deviceId = pushToken;
            APIManager.auth.register(pushToken: pushToken, voipToken: voipToken)
        }
    }

    func pushRegistry(_ registry: PKPushRegistry, didInvalidatePushTokenFor type: PKPushType) {
        let message = "VOIP received registry didInvalidatePushTokenFor : \(registry)"
        NSLog("%@", message)
        print("pushRegistry:didInvalidatePushTokenForType:")
    }
    
    
    func pushRegistry(_ registry: PKPushRegistry, didReceiveIncomingPushWith payload: PKPushPayload, for type: PKPushType, completion: @escaping () -> Void) {
        let message = "VOIP received at didReceiveIncomingPushWith \(payload)"
        NSLog("%@", message)
        if type == .voIP {
            if self.isLoggedIn() == true  {
                CallManager.shared.showCallPopupFromVoip(data: payload, completion: completion)
            } else {
                completion()
            }
            print(payload.dictionaryPayload)
            print("------------ Got Voip Push ----------------")
        }
    }

}

// MARK: - App States
extension AppDelegate {
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        XMPPAppDelegateManager.shared.applicationDidBecomeActive(application)

    }
    func applicationWillResignActive(_ application: UIApplication) {
        print("\n\n*********************\n \(#function) \n*********************\n\n")
//        ChatManager.shared.disconnect()
    }
    


    func applicationDidEnterBackground(_ application: UIApplication) {
        print("\n\n*********************\n \(#function) \n*********************\n\n")
//        ChatManager.shared.disconnect()
        
        //pause audio if playing
        XMPPAppDelegateManager.shared.applicationDidEnterBackground(application)
        AudioPlayerManager.player.pause()

    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        print("\n\n*********************\n \(#function) \n*********************\n\n")
        XMPPAppDelegateManager.shared.applicationWillTerminate(application)

    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        XMPPAppDelegateManager.shared.applicationWillEnterForeground(application)
    }

    func checkRachability(){
        NetworkMonitor.shared.startMonitoring()
    }
}

// MARK: - Push Notifications
extension AppDelegate {

    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        let tokenParts = deviceToken.map { data in String(format: "%02.2hhx", data) }
        let token = tokenParts.joined()
        print("Device Token: \(token)")
        UserDefaults.standard.set(token, forKey: "deviceToken")
        var voipToken = UserDefaults.standard.string(forKey: "voipToken")
        self.token = token
        self.sendAPNSRegistrationCall()
//        let tokenString = deviceToken.reduce("", {$0 + String(format: "%02X", $1)});
        XMPPAppDelegateManager.shared.notificationTokenUpdated(token,error: nil)
    }

    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("[Notifications] didFailToRegisterForRemoteNotificationsWithError: \(error.localizedDescription)")
        XMPPAppDelegateManager.shared.notificationTokenUpdated(nil,error: error)
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        XMPPAppDelegateManager.shared.application(application,didReceiveRemoteNotification:userInfo,fetchCompletionHandler:completionHandler)
        print("Push notification received with fetch request: \(userInfo)");
    }

    func setIQKeyboardManager() {
        IQKeyboardManager.shared.enable = true
        IQKeyboardManager.shared.toolbarTintColor = .black
        IQKeyboardManager.shared.disabledToolbarClasses = [NewPostController.self, SearchController.self, ChatViewController.self, MucChatViewController.self, ConversationLogController.self, SelectFriendsController.self, PostDetailsController.self, ShowStoriesController.self]
        IQKeyboardManager.shared.disabledDistanceHandlingClasses = [ NewPostController.self,ChatViewController.self,MucChatViewController.self, ConversationLogController.self, SearchController.self, SelectFriendsController.self, PostDetailsController.self]
    }
}
