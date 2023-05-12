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
    var activeEnergyBurned: Double = 0.0
    
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
                else {
                    let calendar = Calendar.current
                    let now = Date()
                    let startOfDay = calendar.startOfDay(for: now)
                    let predicate = HKQuery.predicateForSamples(withStart: startOfDay, end: now, options: .strictEndDate)
                    let query = HKStatisticsQuery(quantityType: HKObjectType.quantityType(forIdentifier: .activeEnergyBurned)!, quantitySamplePredicate: predicate, options: .cumulativeSum) { [weak self] (query, result, error) in
                        guard let self = self else { return }
                        if let result = result {
                            self.activeEnergyBurned = result.sumQuantity()?.doubleValue(for: HKUnit.kilocalorie()) ?? 0.0
                        }
                    }
                    healthStore.execute(query)
                    print(self.activeEnergyBurned)
                }
            }
            
            print(activeEnergyBurned)
            
            
            //             Disabling nav controller v
//            guard let navigationController = navigationController else { return }
//            let viewControllers = navigationController.viewControllers.filter { $0 != self }
//            navigationController.setViewControllers(viewControllers, animated: false)
        }
        
    }
    
}

