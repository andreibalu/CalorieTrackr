//
//  ProfileViewController.swift
//  CalorieTrackr
//
//  Created by Andrei Tatucu on 09.06.2023.
//

import UIKit
import WatchConnectivity

class ProfileViewController: UIViewController {
    
    @IBAction func sendStringMessage(_ sender: Any) {
        WatchConnectivityManager.shared.send(createJson(from: jsonObject) ?? "")
    }
    
    func createJson(from jsonObject: [String: Any]) -> String? {
        do {
            // Convert the dictionary to JSON data
            let jsonData = try JSONSerialization.data(withJSONObject: jsonObject, options: .prettyPrinted)
            
            // Convert the JSON data to a string
            if let jsonString = String(data: jsonData, encoding: .utf8) {
                return jsonString
            }
        } catch {
            print("Error: \(error)")
        }
        
        return nil
    }

    let jsonObject: [String: Any] = [
        "burnedCalories": 420,
        "consumedCalories": 1337,
        "proteins": 69,
        "carbs": 13,
        "fats": 10
    ]

    
    private let kMessageKey = "message"
        
    func send(_ message: String) {
        guard WCSession.default.activationState == .activated else {
          return
        }
        #if os(iOS)
        guard WCSession.default.isWatchAppInstalled else {
            return
        }
        #else
        guard WCSession.default.isCompanionAppInstalled else {
            return
        }
        #endif
        
        WCSession.default.sendMessage([kMessageKey : message], replyHandler: nil) { error in
            print("Cannot send message: \(String(describing: error))")
        }
    }



}
