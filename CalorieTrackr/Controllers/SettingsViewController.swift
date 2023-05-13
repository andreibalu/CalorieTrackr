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
        print("apasat")
        do {
            try Auth.auth().signOut()
            tabBarDelegate?.logoutAndNavigateToWelcome()
        } catch let signOutError as NSError {
            print("Error signing out: %@", signOutError)
        }
    }
}
