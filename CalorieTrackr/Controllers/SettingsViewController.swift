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

protocol TabBarDelegate: AnyObject {
    func logoutAndNavigateToWelcome()
}

class SettingsViewController: UIViewController {
    
    let db = Firestore.firestore()
    @IBOutlet weak var titleLabel: UILabel!
    weak var tabBarDelegate: TabBarDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //
    }
    @IBAction func logoutPressed(_ sender: UIButton) {
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
}
