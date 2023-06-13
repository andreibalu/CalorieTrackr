//
//  AppDelegate.swift
//  CalorieTrackr
//
//  Created by Andrei Baluta on 22.04.2023.
//

import UIKit
import FirebaseCore
import FirebaseFirestore
import FirebaseAuth
import WatchConnectivity

@main
class AppDelegate: UIResponder, UIApplicationDelegate , WCSessionDelegate {
    
    var window: UIWindow?
    var session: WCSession?
    var timer: Timer?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        FirebaseApp.configure()
        let foodService = FoodService()
        let homeVC = HomeViewController()
        foodService.refreshForToday()
        homeVC.updateStreak()
        
        if WCSession.isSupported() {
            session = WCSession.default
            session?.delegate = self
            session?.activate()
        }

        // Start timer to send JSON every minute
        timer = Timer.scheduledTimer(timeInterval: 2, target: self, selector: #selector(sendEmptyJSON), userInfo: nil, repeats: true)

        return true
    }
    
    @objc func sendEmptyJSON() {
        guard WCSession.default.isReachable else {
            return
        }

        let message: [String: Any] = ["message":"empty"]

        session?.sendMessage(message, replyHandler: nil, errorHandler: { error in
            print("Failed to send JSON: \(error)")
        })
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
    
    func sessionDidBecomeInactive(_ session: WCSession) {
        // Empty implementation
    }
    
    func sessionDidDeactivate(_ session: WCSession) {
        // Empty implementation
    }
    
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        // Empty implementation
    }

}

