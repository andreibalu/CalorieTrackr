//
//  HomeViewController.swift
//  CalorieTrackr
//
//  Created by Andrei Baluta on 22.04.2023.
//
import UIKit
import FirebaseCore
import FirebaseFirestore
import FirebaseAuth
//    @IBAction func logoutPressed(_ sender: UIButton) {
//        do {
//            try Auth.auth().signOut()
//            navigationController?.popToRootViewController(animated: true)
//        } catch let signOutError as NSError {
//            print("Error signing out: %@", signOutError)
//        }
//    }
//    must be moved to settings screen

import HealthKit

class HomeViewController: UIViewController {
    
    @IBOutlet weak var titleLabel: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        if HKHealthStore.isHealthDataAvailable() {
            print("yes")
            let healthStore = HKHealthStore()
            let allTypes = Set([HKObjectType.quantityType(forIdentifier: .activeEnergyBurned)!])

            healthStore.requestAuthorization(toShare: allTypes, read: allTypes) { (success, error) in
                if !success {
                    let alert = UIAlertController(title: "HealthKit error", message: error?.localizedDescription, preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                }
            }
        }
        
        
        // Disabling nav controller
        guard let navigationController = navigationController else { return }
        let viewControllers = navigationController.viewControllers.filter { $0 != self }
        navigationController.setViewControllers(viewControllers, animated: false)
    }
    
}





