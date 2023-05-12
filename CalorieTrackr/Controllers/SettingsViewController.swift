//
//  SettingsViewController.swift
//  CalorieTrackr
//
//  Created by Andrei Baluta on 12.05.2023.
//

import UIKit
import FirebaseCore
import FirebaseFirestore
import FirebaseAuth

class SettingsViewController: UIViewController {
    
    let db = Firestore.firestore()
    @IBOutlet weak var titleLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //
    }
    @IBAction func logoutPressed(_ sender: UIButton) {
        print("apasat")
        do {
            try Auth.auth().signOut()
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            if let welcomeViewController = storyboard.instantiateViewController(withIdentifier: K.logout) as? WelcomeViewController {
                // Set up the navigation controller with the login view controller
                let navController = UINavigationController(rootViewController: welcomeViewController)
                navController.modalPresentationStyle = .fullScreen
                
                // Replace the current view controllers with the login view controller
                self.navigationController?.setViewControllers([welcomeViewController], animated: true)
            }
        } catch let signOutError as NSError {
            print("Error signing out: %@", signOutError)
        }
    }
}
