//
//  AppDelegate.swift
//  ReciFoto
//
//  Created by Colin Taylor on 1/18/17.
//  Copyright © 2017 Colin Taylor. All rights reserved.
//

import UIKit
import CoreData
import UserNotifications
import FBSDKCoreKit
import Fabric
import TwitterKit
import Crashlytics

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        Fabric.with([Crashlytics.self, Twitter.self])

        UIApplication.shared.registerForRemoteNotifications()
        if hasLoginInfo() {
            loadFromUserDefaults()
            changeRootViewController(with: "mainTabVC")
        }
        return FBSDKApplicationDelegate.sharedInstance().application(application, didFinishLaunchingWithOptions: launchOptions)
    }
    
    
    func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
        return FBSDKApplicationDelegate.sharedInstance().application(application, open: url, sourceApplication: sourceApplication, annotation: annotation)
    }
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
        FBSDKAppEvents.activateApp()
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
        // Saves changes in the application's managed object context before the application terminates.
        self.saveContext()
    }
    // MARK: - Utilization
    func changeRootViewController(with identifier:String!) {
        let storyboard = self.window?.rootViewController?.storyboard
        let desiredViewController = storyboard?.instantiateViewController(withIdentifier: identifier);
        
        let snapshot:UIView = (self.window?.snapshotView(afterScreenUpdates: true))!
        desiredViewController?.view.addSubview(snapshot);
        
        self.window?.rootViewController = desiredViewController;
        
        UIView.animate(withDuration: 0.3, animations: {() in
            snapshot.layer.opacity = 0;
            snapshot.layer.transform = CATransform3DMakeScale(1.5, 1.5, 1.5);
        }, completion: {
            (value: Bool) in
            snapshot.removeFromSuperview();
        });
    }
    func saveToUserDefaults(){
        let defaults = UserDefaults.standard
        
        defaults.set(Me.user.userEmail, forKey: Constants.USER_EMAIL_KEY)
        defaults.set(Me.user.id, forKey: Constants.USER_ID_KEY)
        defaults.set(Me.session_id, forKey: Constants.USER_SESSION_KEY)
        defaults.set(Me.user.userName, forKey: Constants.USER_NAME_KEY)
        
        defaults.synchronize()
    }
    func loadFromUserDefaults(){
        let defaults = UserDefaults.standard
        
        Me.session_id = defaults.string(forKey: Constants.USER_SESSION_KEY)!
        Me.user.userName = defaults.string(forKey: Constants.USER_NAME_KEY)!
        Me.user.id = defaults.string(forKey: Constants.USER_ID_KEY)!
        Me.user.userEmail = defaults.string(forKey: Constants.USER_EMAIL_KEY)!
    }
    func isFirstLaunch() -> Bool {
        let launchedBefore = UserDefaults.standard.bool(forKey: Constants.LAUNCHED_BEFORE_KEY)
        if launchedBefore  {
            return false
        } else {
            UserDefaults.standard.set(true, forKey: Constants.LAUNCHED_BEFORE_KEY)
            return true
        }
    }
    func hasLoginInfo() -> Bool{
        return UserDefaults.standard.bool(forKey: Constants.HAS_LOGIN_KEY)
    }
    func setHasLoginInfo(status: Bool) {
        UserDefaults.standard.set(status, forKey: Constants.HAS_LOGIN_KEY)
    }
    
    // MARK: - Core Data stack
    
    lazy var persistentContainer: NSPersistentContainer = {
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
        */
        let container = NSPersistentContainer(name: "ReciFoto")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                 
                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()

    // MARK: - Core Data Saving support

    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
    // MARK: - Push Notification Registration
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        var token = ""
        for i in 0..<deviceToken.count {
            token = token + String(format: "%02.2hhx", arguments: [deviceToken[i]])
        }
        Me.device_token = token
    }
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("Failed to register:", error)
    }
}

