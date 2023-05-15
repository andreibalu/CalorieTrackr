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
    
    let db = Firestore.firestore()
    
    
    @IBOutlet weak var circleView: UIView!
    @IBOutlet weak var muscleImage: UIImageView!
    @IBOutlet weak var streakLabel: UILabel!
    @IBOutlet weak var targetLabel: UILabel!
    @IBOutlet weak var messageLabel: UILabel!
    
    var activeEnergyBurned: Double = 0.0
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        healthAuthAndGetEnergy()
        
        circleView.layer.borderWidth = 0.0 // Set border width to 0
        circleView.layer.borderColor = UIColor.clear.cgColor // Set border color to clear color
        circleView.layer.cornerRadius = circleView.frame.size.width / 2.0
        circleView.clipsToBounds = true
        muscleImage.image = UIImage(imageLiteralResourceName: K.Images.muscle)
        
        if let currentUser = Auth.auth().currentUser?.email{
            print(currentUser as Any)
            let userDocumentRef = db.collection(K.FStore.collectionName).document(currentUser)
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                userDocumentRef.getDocument { (document, error) in
                    if let document = document, document.exists {
                        if let streakValue = document.data()?[K.FStore.streak] as? String {
                            self.animateLabelChange(label: self.streakLabel, newText: "Streak: \(streakValue) days", duration: 1)
                            // self.streakLabel.text = "Streak: \(fieldValue) days"
                        }
                        if let targetValue = document.data()?[K.FStore.target] as? String {
                            self.animateLabelChange(label: self.targetLabel, newText: "Target: \(targetValue) calories", duration: 1)
                        }
                    } else {
                        print("Error at retrieving data from database \(String(describing: error?.localizedDescription))")
                    }
                }
                
            }
        }
        
    }
    
    // Use the activeEnergyBurned variable for further processing or display
    func handleActiveEnergyBurnedValue(_ value: Double) {
        print("Active Energy Burned: \(value)")
        
        let currentValue = activeEnergyBurned
        let targetValue = 1500.0            //must replace with user's target, calculated in survey logic feature
        updateCircleProgress(currentValue: currentValue, targetValue: targetValue)
        
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: circleView.frame.size.width, height: circleView.frame.size.height))
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 18.0)
        label.textColor = UIColor.black
        //        animateLabelChange(label: label, newText: "You've burned \(String(Int(currentValue))) calories", duration: 1)
        label.text = "You've burned \(String(Int(currentValue))) calories"
        
        
    }
    //Makes sure the view makes a circle
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        circleView.layer.cornerRadius = circleView.frame.size.width / 2.0
    }
    
    func healthAuthAndGetEnergy(){
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
    
    func updateCircleProgress(currentValue: Double, targetValue: Double) {
        let progress = currentValue / targetValue
        
        let circlePath = UIBezierPath(
            arcCenter: CGPoint(x: circleView.frame.size.width / 2.0, y: circleView.frame.size.height / 2.0),
            radius: (circleView.frame.size.width - 4.0) / 2.0,
            startAngle: -CGFloat.pi / 2.0,
            endAngle: CGFloat(progress * 2.0 * Double.pi) - CGFloat.pi / 2.0,
            clockwise: true
        )
        
        let shapeLayer = CAShapeLayer()
        shapeLayer.path = circlePath.cgPath
        shapeLayer.strokeColor = UIColor.green.cgColor
        shapeLayer.fillColor = UIColor.clear.cgColor
        shapeLayer.lineWidth = 10.0 // Set a thicker line width
        shapeLayer.lineCap = .round
        
        let animation = CABasicAnimation(keyPath: "strokeEnd")
        animation.fromValue = 0.0
        animation.toValue = progress
        animation.duration = 1.0 // Set the duration of the animation
        
        shapeLayer.add(animation, forKey: "progressAnimation")
        
        let remainingPath = UIBezierPath(
            arcCenter: CGPoint(x: circleView.frame.size.width / 2.0, y: circleView.frame.size.height / 2.0),
            radius: (circleView.frame.size.width - 4.0) / 2.0,
            startAngle: CGFloat(progress * 2.0 * Double.pi) - CGFloat.pi / 2.0,
            endAngle: -CGFloat.pi / 2.0,
            clockwise: true
        )
        
        let remainingShapeLayer = CAShapeLayer()
        remainingShapeLayer.path = remainingPath.cgPath
        remainingShapeLayer.strokeColor = UIColor.lightGray.cgColor // Customize the color for the remaining progress
        remainingShapeLayer.fillColor = UIColor.clear.cgColor
        remainingShapeLayer.lineWidth = 10.0 // Set a thicker line width
        remainingShapeLayer.lineCap = .round
        
        circleView.layer.sublayers?.forEach { $0.removeFromSuperlayer() }
        circleView.layer.addSublayer(remainingShapeLayer)
        circleView.layer.addSublayer(shapeLayer)
    }
    
    func animateLabelChange(label: UILabel, newText: String, duration: TimeInterval) {
        UIView.transition(with: label, duration: duration, options: .transitionCrossDissolve, animations: {
            label.text = newText
        }, completion: nil)
    }
}

