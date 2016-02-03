//
//  AppDelegate.swift
//  vlogger
//
//  Created by Eric Smith on 1/4/16.
//  Copyright © 2016 smith1302. All rights reserved.
//

import UIKit
import Parse
import Bolts
import AVFoundation

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        User.registerSubclass()
        Video.registerSubclass()
        Like.registerSubclass()
        Follow.registerSubclass()
        Flag.registerSubclass()
        VideoUpdates.registerSubclass()
        Story.registerSubclass()
        // [Optional] Power your app with Local Datastore. For more info, go to
        // https://parse.com/docs/ios/guide#local-datastore
        //Parse.enableLocalDatastore()
        // Initialize Parse.
        Parse.setApplicationId("qrUlUCuzG0Vw9132ZPVuOgguGBkkoXYUbHOs92y0",
            clientKey: "ywLAE0P5enBKEwF0zgq3wlUawzklf5aZBXwXspqY")
        
        // [Optional] Track statistics around application opens.
        PFAnalytics.trackAppOpenedWithLaunchOptions(launchOptions)
        
        let storyboard = UIStoryboard(name: "Main", bundle: NSBundle.mainBundle());
        let currentUser = PFUser.currentUser()
        if currentUser != nil {
            self.window?.rootViewController = storyboard.instantiateViewControllerWithIdentifier("MainNavigationViewController");
        }
        
        // Set appearance for NavigationBar
        UINavigationBar.appearance().shadowImage = UIImage()
        UINavigationBar.appearance().setBackgroundImage(UIImage(), forBarMetrics: UIBarMetrics.Default)
        UINavigationBar.appearance().translucent = false
        UINavigationBar.appearance().barTintColor = Constants.primaryColor
        UINavigationBar.appearance().tintColor = Constants.textOnPrimaryColor
        UINavigationBar.appearance().titleTextAttributes = [NSForegroundColorAttributeName: Constants.textOnPrimaryColor]
        
        // Set appearance for BarButtonItems
        UIBarButtonItem.appearance().setTitleTextAttributes([NSFontAttributeName: UIFont.systemFontOfSize(16), NSForegroundColorAttributeName: UIColor.whiteColor()], forState: UIControlState.Normal)
        // Check version change
        Utilities.updateUsersAppVersion()
        
        
        if application.applicationState != UIApplicationState.Background {
            // Track an app open here if we launch with a push, unless
            // "content_available" was used to trigger a background push (introduced in iOS 7).
            // In that case, we skip tracking here to avoid double counting the app-open.
            
            let preBackgroundPush = !application.respondsToSelector("backgroundRefreshStatus")
            let oldPushHandlerOnly = !self.respondsToSelector("application:didReceiveRemoteNotification:fetchCompletionHandler:")
            var noPushPayload = false;
            if let options = launchOptions {
                noPushPayload = options[UIApplicationLaunchOptionsRemoteNotificationKey] != nil;
            }
            if (preBackgroundPush || oldPushHandlerOnly || noPushPayload) {
                PFAnalytics.trackAppOpenedWithLaunchOptions(launchOptions)
            }
        }
        
        return true
    }
    
    //--------------------------------------
    // MARK: Push Notifications
    //--------------------------------------
    
    func application(application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: NSData) {
        let installation = PFInstallation.currentInstallation()
        installation.setDeviceTokenFromData(deviceToken)
        installation.saveInBackground()
        
        PFPush.subscribeToChannelInBackground("") { (succeeded: Bool, error: NSError?) in
            if succeeded {
                //print("ParseStarterProject successfully subscribed to push notifications on the broadcast channel.\n");
            } else {
                //print("ParseStarterProject failed to subscribe to push notifications on the broadcast channel with error = %@.\n", error)
            }
        }
    }
    
    func application(application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: NSError) {
        if error.code == 3010 {
            print("Push notifications are not supported in the iOS Simulator.\n")
        } else {
            print("application:didFailToRegisterForRemoteNotificationsWithError: %@\n", error)
        }
    }
    
    func application(application: UIApplication, didReceiveRemoteNotification userInfo: [NSObject : AnyObject]) {
        PFPush.handlePush(userInfo)
        if application.applicationState == UIApplicationState.Inactive {
            PFAnalytics.trackAppOpenedWithRemoteNotificationPayload(userInfo)
        }
    }
    
    func applicationDidBecomeActive(application: UIApplication) {
        Utilities.setAudioSessionCategory(AVAudioSessionCategorySoloAmbient)
        
        let currentInstallation = PFInstallation.currentInstallation()
        if currentInstallation.badge != 0 {
            currentInstallation.badge = 0
            currentInstallation.saveEventually()
        }
    }
    
    // ----------------------

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

