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

import HealthKit

class HomeViewController: UIViewController {
    
    @IBOutlet weak var caloriesBurned: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var circleView: UIView!
    var activeEnergyBurned: Double = 0.0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        calculateCaloriesFromHealth()
    }
    
    // Use the activeEnergyBurned variable for further processing or display
    func handleActiveEnergyBurnedValue(_ value: Double) {
        print("Active Energy Burned: \(value)")
        caloriesBurned.text = "Ai ars " + String(format:"%.0f",activeEnergyBurned)
    }
    
    func calculateCaloriesFromHealth(){
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
    
    //today calories
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
}

