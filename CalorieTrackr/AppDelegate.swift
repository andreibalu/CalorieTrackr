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

        timer = Timer.scheduledTimer(timeInterval: 5, target: self, selector: #selector(sendJSON), userInfo: nil, repeats: true)

        return true
    }
    
    @objc func sendJSON() {
        guard WCSession.default.isReachable else {
            return
        }
        WatchConnectivityManager.shared.send(createJson(from: createDataJson()) ?? "")
    }
    
    func createDataJson() -> [String:Any]
    {
        print("Tatucu: \(UserDefaults.standard.object(forKey: "bmr") as? Double ?? 0)")
        var jsonObject: [String: Any] = [
            "consumedCalories": UserDefaults.standard.object(forKey: "consumed") as? Double ?? "0",
            "proteins": UserDefaults.standard.object(forKey: "proteins") as? Double ?? "0",
            "carbs": UserDefaults.standard.object(forKey: "carbs") as? Double ?? "0",
            "fats": UserDefaults.standard.object(forKey: "fats") as? Double ?? "0",
            "bmr": UserDefaults.standard.object(forKey: "bmr") as? Double ?? 0,
            "consumed1": UserDefaults.standard.object(forKey: "consumed1") as? String ?? "",
            "consumed2": UserDefaults.standard.object(forKey: "consumed2") as? String ?? "",
            "consumed3": UserDefaults.standard.object(forKey: "consumed3") as? String ?? "",
            "burned1": UserDefaults.standard.object(forKey: "burned1") as? String ?? "",
            "burned2": UserDefaults.standard.object(forKey: "burned2") as? String ?? "",
            "burned3": UserDefaults.standard.object(forKey: "burned3") as? String ?? "",
            "streak1": UserDefaults.standard.object(forKey: "streak1") as? String ?? "",
            "streak2": UserDefaults.standard.object(forKey: "streak2") as? String ?? "",
            "streak3": UserDefaults.standard.object(forKey: "streak3") as? String ?? ""
        ]
        return jsonObject
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

