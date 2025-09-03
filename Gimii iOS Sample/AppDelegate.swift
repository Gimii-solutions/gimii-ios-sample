//
//  AppDelegate.swift
//  Gimii iOS Sample
//
//  Created by Léo Giroux on 03/09/2025.
//

import UIKit
import Didomi
import GimiiSDK

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
  
  func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
    // Override point for customization after application launch.
    let parameters = DidomiInitializeParameters(apiKey: "API_KEY", noticeID: "NOTICE_ID")
    
    Didomi.shared.initialize(parameters)
    
    // Important: views should not wait for onReady to be called.
    // You might want to execute code here that needs the Didomi SDK
    // to be initialized such us: analytics and other non-IAB vendors.
    return true
  }
  
  // MARK: UISceneSession Lifecycle
  
  func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
    // Called when a new scene session is being created.
    // Use this method to select a configuration to create the new scene with.
    return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
  }
  
  func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
    // Called when the user discards a scene session.
    // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
    // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
  }
}
