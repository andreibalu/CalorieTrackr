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

    @IBOutlet weak var caloriesBurned: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    var activeEnergyBurned: Double = 0.0

    override func viewDidLoad() {
        super.viewDidLoad()
        if HKHealthStore.isHealthDataAvailable() {
            print("Can read health")
            let healthStore = HKHealthStore()
            let energyType = HKObjectType.quantityType(forIdentifier: .activeEnergyBurned)!

            healthStore.requestAuthorization(toShare: nil, read: [energyType]) { (success, error) in
                if !success {
                    let alert = UIAlertController(title: "Auth HealthKit Error", message: error?.localizedDescription, preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                } else {
                    self.fetchActiveEnergyBurned(from: healthStore, energyType: energyType)
                }
            }
        }
    }
    
    //catch calories
    func fetchActiveEnergyBurned(from healthStore: HKHealthStore, energyType: HKObjectType) {
        let calendar = Calendar.current
        let now = Date()
        let startDate = calendar.startOfDay(for: now)
        let endDate = calendar.date(byAdding: .day, value: 1, to: startDate)
        let predicate = HKQuery.predicateForSamples(withStart: startDate, end: endDate, options: .strictStartDate)

        let query = HKSampleQuery(sampleType: energyType as! HKSampleType, predicate: predicate, limit: HKObjectQueryNoLimit, sortDescriptors: nil) { (query, results, error) in
            if let error = error {
                let alert = UIAlertController(title: "Query from HealthKit Error", message: error.localizedDescription, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                self.present(alert, animated: true, completion: nil)
                return
            }

            if let samples = results as? [HKQuantitySample] {
                let totalEnergyBurned = samples.reduce(0.0) { $0 + $1.quantity.doubleValue(for: HKUnit.kilocalorie()) }

                DispatchQueue.main.async {
                    self.activeEnergyBurned = totalEnergyBurned
                    self.handleActiveEnergyBurnedValue(self.activeEnergyBurned)
                }
            }
        }
        healthStore.execute(query)
    }

    // Use the activeEnergyBurned variable for further processing or display
    func handleActiveEnergyBurnedValue(_ value: Double) {
        print("Active Energy Burned: \(value)")
        caloriesBurned.text = "Ai ars " + String(format:"%.0f",activeEnergyBurned)
    }
}

//             Disabling nav controller v
//            guard let navigationController = navigationController else { return }
//            let viewControllers = navigationController.viewControllers.filter { $0 != self }
//            navigationController.setViewControllers(viewControllers, animated: false)

