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


protocol TabBarDelegate: AnyObject {
    func logoutAndNavigateToWelcome()
}

class OutlinedLabel: UILabel {
    var outlineColor: UIColor = .black
    var outlineWidth: CGFloat = 1.0
    var boxColor: UIColor = .white
    
    override func drawText(in rect: CGRect) {
            // Draw white background rectangle
            let backgroundRect = rect.insetBy(dx: -outlineWidth, dy: -outlineWidth)
            let backgroundPath = UIBezierPath(rect: backgroundRect)
            boxColor.setFill()
            backgroundPath.fill()
            
            // Draw outlined text
            let strokeTextAttributes: [NSAttributedString.Key: Any] = [
                .foregroundColor: textColor,
                .strokeColor: outlineColor,
                .strokeWidth: -outlineWidth,
            ]
            attributedText = NSAttributedString(string: text ?? "", attributes: strokeTextAttributes)
            super.drawText(in: rect)
        }
}

class ProfileViewController: UIViewController {
    let db = Firestore.firestore()
    weak var tabBarDelegate: TabBarDelegate?
    private var following : [String] = []
    private var followers : [String] = []
    private var userEmails: [String] = []
    
    @IBOutlet weak var idLabel: UILabel!
    
    @IBOutlet weak var nameLabel: OutlinedLabel!
    @IBOutlet weak var levelLabel: OutlinedLabel!
    
    @IBOutlet weak var sexLabel: OutlinedLabel!
    @IBOutlet weak var heightLabel: OutlinedLabel!
    
    @IBOutlet weak var weightLabel: OutlinedLabel!
    @IBOutlet weak var idealWeightLabel: OutlinedLabel!
    
    @IBOutlet weak var streakLabel: OutlinedLabel!
    @IBOutlet weak var followingButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.followingButton.titleLabel?.text = UserDefaults.standard.object(forKey: "followingCount") as? String
        self.nameLabel.text = UserDefaults.standard.object(forKey: "name") as? String
        self.heightLabel.text = UserDefaults.standard.object(forKey: "height") as? String
        self.weightLabel.text = UserDefaults.standard.object(forKey: "weight") as? String
        self.idealWeightLabel.text = UserDefaults.standard.object(forKey: "idealWeight") as? String
        
        if let currentUser = Auth.auth().currentUser?.email{
            print(currentUser as Any)
            let userDocumentRef = db.collection(K.FStore.collectionName).document(currentUser)
            DispatchQueue.main.asyncAfter(deadline: .now()) {
                userDocumentRef.getDocument { (document, error) in
                    if let document = document, document.exists {
                        if let followingValue = document.data()?["following"] as? [String]
                        {
                            self.following = followingValue
                            self.followingButton.setTitle("\(followingValue.count) friends", for: .normal)
                            UserDefaults.standard.set(followingValue.count, forKey: "followingCount")
                        }
                        if let nameValue = document.data()?["Name"] as? String
                        {
                            UserDefaults.standard.set(nameValue, forKey: "name")
                            self.nameLabel.text = nameValue
                        }
                        if let idValue = document.data()?["Email"] as? String
                        {
                            UserDefaults.standard.set(idValue, forKey: "email")
                            self.idLabel.text = idValue
                        }
                        if let streakValue = document.data()?["streak"] as? Int
                        {
                            UserDefaults.standard.set(streakValue, forKey: "streak")
                            self.streakLabel.text = "\(streakValue) days"
                            if (streakValue < 5)
                            {
                                self.levelLabel.text = "Wonderer"
                            }
                            else if (streakValue >= 5 && streakValue < 20)
                            {
                                self.levelLabel.text = "Fighter"
                            }
                            else if (streakValue >= 20 && streakValue < 40)
                            {
                                self.levelLabel.text = "Warrior"
                            }
                            else if (streakValue >= 40 && streakValue < 80)
                            {
                                self.levelLabel.text = "Captain"
                            }
                            else if (streakValue >= 80 && streakValue < 130)
                            {
                                self.levelLabel.text = "General"
                            }
                            else if (streakValue >= 130)
                            {
                                self.levelLabel.text = "Special Agent"
                            }
                        }
                        if let heightValue = document.data()?["Height"] as? String
                        {
                            UserDefaults.standard.set(heightValue, forKey: "height")
                            self.heightLabel.text = "\(heightValue) cm"
                        }
                        if let weightValue = document.data()?["Weight"] as? String
                        {
                            UserDefaults.standard.set(weightValue, forKey: "weight")
                            self.weightLabel.text = "\(weightValue) kg"
                            
                        }
                        if let sexValue = document.data()?["Sex"] as? String
                        {
                            UserDefaults.standard.set(sexValue, forKey: "sex")
                            self.sexLabel.text = "\(sexValue)"
                            
                        }
                        if let idealWeightValue = document.data()?["IdealWeight"] as? String
                        {
                            UserDefaults.standard.set(idealWeightValue, forKey: "idealWeight")
                            self.idealWeightLabel.text = "\(idealWeightValue) kg"
                        }
                    }
                }
            }
        }
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
    
    func createJson(from jsonObject: [String: Any]) -> String? {
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: jsonObject, options: .prettyPrinted)
            
            if let jsonString = String(data: jsonData, encoding: .utf8) {
                return jsonString
            }
        } catch {
            print("Error: \(error)")
        }
        return nil
    }

    
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
