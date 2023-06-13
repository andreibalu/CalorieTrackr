//
//  ProfileViewController.swift
//  CalorieTrackr
//
//  Created by Andrei Tatucu on 09.06.2023.
//

import UIKit
import WatchConnectivity
import FirebaseCore
import FirebaseFirestore
import FirebaseAuth


//protocol TabBarDelegate: AnyObject {
//    func logoutAndNavigateToWelcome()
//}

class ProfileViewController: UIViewController {
    let db = Firestore.firestore()
    weak var tabBarDelegate: TabBarDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //
    }
    
    @IBAction func logoutButtonAction(_ sender: UIButton) {
        let alertController = UIAlertController(title: "Confirm Logout", message: "Are you sure you want to log out?", preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        let confirmAction = UIAlertAction(title: "Log Out", style: .destructive) { (_) in
            do {
                try Auth.auth().signOut()
                self.tabBarDelegate?.logoutAndNavigateToWelcome()
            } catch let error as NSError {
                print("Error signing out: %@", error.localizedDescription)
            }
        }
        alertController.addAction(cancelAction)
        alertController.addAction(confirmAction)
        
        present(alertController, animated: true, completion: nil)
    }
    
    @IBAction func accountSettingsButton(_ sender: Any) {
    }
    @IBAction func sendStringMessage(_ sender: Any) {
        //WatchConnectivityManager.burnedCalories = 5
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
    

    var jsonObject: [String: Any] = [
        "burnedCalories": 420,
        "consumedCalories": 1337,
        "proteins": 69,
        "carbs": 13,
        "fats": 10
    ]

    
    private let kMessageKey = "message"
    
    var bufferMessage = ""
        
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
            self.bufferMessage = message
        }
    }



}
