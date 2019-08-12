//
//  AppDelegate.swift
//  Fun
//
//  Created by Jake Rein on 12/19/18.
//  Copyright © 2018 Jake Rein. All rights reserved.
//

import UIKit
import GoogleCast
import Casty
import AVFoundation

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, GCKLoggerDelegate {

    var backgroundSessionCompletionHandler : (() -> Void)?
    
    var window: UIWindow?
    
    let kReceiverAppID = "CC1AD845"
    let kDebugLoggingEnabled = true

    func application(_ application: UIApplication, handleEventsForBackgroundURLSession identifier: String, completionHandler: @escaping () -> Void) {
        debugPrint("handleEventsForBackgroundURLSession: \(identifier)")
        completionHandler()
        backgroundSessionCompletionHandler = completionHandler
    }

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        // Set your receiver application ID.
        Casty.shared.setupCasty(appId: kReceiverAppID, useExpandedControls: true)
        let criteria = GCKDiscoveryCriteria(applicationID: kReceiverAppID)
        let options = GCKCastOptions(discoveryCriteria: criteria)
        options.physicalVolumeButtonsWillControlDeviceVolume = true
        GCKCastContext.setSharedInstanceWith(options)
        
        // Configure widget styling.
        // Theme using UIAppearance.
        UINavigationBar.appearance().barTintColor = .lightGray
        let colorAttributes = [NSAttributedString.Key.foregroundColor: UIColor.black]
        UINavigationBar().titleTextAttributes = colorAttributes
        GCKUICastButton.appearance().tintColor = .gray
        
        // Theme using GCKUIStyle.
        let castStyle = GCKUIStyle.sharedInstance()
        // Set the property of the desired cast widgets.
        castStyle.castViews.deviceControl.buttonTextColor = .darkGray
        // Refresh all currently visible views with the assigned styles.
        castStyle.apply()
        
        // Enable default expanded controller.
        GCKCastContext.sharedInstance().useDefaultExpandedMediaControls = true
        
        // Enable logger.
        GCKLogger.sharedInstance().delegate = self
        
        // Set logger filter.
        let filter = GCKLoggerFilter()
        filter.minimumLevel = .error
        GCKLogger.sharedInstance().filter = filter
        
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setCategory(.playback, mode: .moviePlayback)
        }
        catch {
            print("Setting category to AVAudioSessionCategoryPlayback failed.")
        }
        return true
        
//        // Wrap main view in the GCKUICastContainerViewController and display the mini controller.
//        let appStoryboard = UIStoryboard(name: "Main", bundle: nil)
//        let navigationController = appStoryboard.instantiateViewController(withIdentifier: "navcontrol")
//        let castContainerVC = GCKCastContext.sharedInstance().createCastContainerController(for: navigationController)
//        castContainerVC.miniMediaControlsItemEnabled = true
//        // Color the background to match the embedded content
//        castContainerVC.view.backgroundColor = .white
//
//        window = UIWindow(frame: UIScreen.main.bounds)
//        window?.rootViewController = castContainerVC
//        window?.makeKeyAndVisible()
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }

    func application(_ application: UIApplication, supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask{
        return .portrait
    }
    
    func logMessage(_ message: String,
                    at _: GCKLoggerLevel,
                    fromFunction function: String,
                    location: String) {
        if kDebugLoggingEnabled {
            print("\(location): \(function) - \(message)")
        }
    }

}

