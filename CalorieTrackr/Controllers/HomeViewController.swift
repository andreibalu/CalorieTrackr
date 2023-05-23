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
    
    private let db = Firestore.firestore()
    private var foodService: FoodService!
    
    @IBOutlet weak var circleView: UIView!
    @IBOutlet weak var muscleImage: UIImageView!
    @IBOutlet weak var streakLabel: UILabel!
    @IBOutlet weak var targetLabel: UILabel!
    @IBOutlet weak var messageLabel: UILabel!
    
    private var activeEnergyBurned: Double = 0.0
    private var target : Int = 0
    private var streak : Int = 0
    private var weight : Int = 0
    private var ideal : Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        foodService = FoodService()
        
        healthAuthAndGetEnergy()
        circleProperties()
        animateCircleAppearance()
        NotificationCenter.default.addObserver(self, selector: #selector(self.handleActiveEnergyBurnedValue(_:)), name: NSNotification.Name(rawValue: K.Api.food.notif), object: nil)
        
        muscleImage.image = UIImage(imageLiteralResourceName: K.Images.muscle)
        
        if let currentUser = Auth.auth().currentUser?.email{
            print(currentUser as Any)
            let userDocumentRef = db.collection(K.FStore.collectionName).document(currentUser)
            DispatchQueue.main.asyncAfter(deadline: .now()) {  // maybe add a few secs if errors
                userDocumentRef.getDocument { (document, error) in
                    if let document = document, document.exists {
                        if let streakValue = document.data()?[K.FStore.streak] as? String {
                            self.streak = Int(streakValue)!
                            print("streakValue in auth: \(streakValue) days")
                            self.animateLabelChange(label: self.streakLabel, newText: "Streak: \(streakValue) days", duration: 1)
                        }
                        if let targetValue = document.data()?[K.FStore.target] as? String {
                            self.target = Int(targetValue)!
                            print("targetValue in auth: \(targetValue) cals")
                            self.animateLabelChange(label: self.targetLabel, newText: "Target: \(targetValue) calories", duration: 1)
                        }
                        if let weightValue = document.data()?[K.FStore.weight] as? String {
                            self.weight = Int(weightValue)!
                            print("weightValue in auth: \(weightValue) kg")
                        }
                        if let idealValue = document.data()?[K.FStore.ideal] as? String {
                            self.ideal = Int(idealValue)!
                            print("idealValue in auth: \(idealValue) kg")
                        }
                    } else {
                        print("Error at retrieving data from database \(String(describing: error?.localizedDescription))")
                    }
                }
                
            }
        }
        
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    // Use the activeEnergyBurned variable after fetching it
    @objc func handleActiveEnergyBurnedValue(_ value: Double) {
        Timer.scheduledTimer(withTimeInterval: 2.5, repeats: false) { [self] Timer in
            print("Fetched Active Energy Burned: \(value).")
            
            let currentValue = self.foodService.getTotalCaloriesFromMealFile() - activeEnergyBurned
            let targetValue = Double(target)
            print("Current food-burned=\(self.foodService.getTotalCaloriesFromMealFile()) - \(activeEnergyBurned) and target in circle=\(targetValue)")
            if currentValue < 0 {                                                               //OUTCOME 1->Cals burned> cals ate
                updateCircleProgress(currentValue: 0.0, targetValue: targetValue)
                setUpLabels(current: currentValue, target: targetValue,
                            needText: "Eat something!",
                            burnedText: "You've burned \(Int(activeEnergyBurned)) calories today, but ate none !")
            }
            else {                                                                              //OUTCOME 2 OR 3 -> PROGRESSING TO TARGET
                if (targetValue > currentValue) {
                    updateCircleProgress(currentValue: currentValue, targetValue: targetValue)
                    setUpLabels(current: currentValue, target: targetValue,                    //OUTCOME 2->Cals burned< cals ate
                                needText: "You still need \(Int(targetValue) - Int(currentValue)) calories.",
                                burnedText: "You've burned \(Int(activeEnergyBurned)) calories today!")
                    
                } else {
                    if ( weight < ideal) {
                        updateCircleProgress(currentValue: currentValue, targetValue: targetValue)          //OUTCOME 3-> TARGET REACHED and can go on
                        setUpLabels(current: currentValue, target: targetValue,
                                    needText: "You did it! You have \(Int(currentValue) - Int(targetValue)) extra calories.",
                                    burnedText: "You've burned \(Int(activeEnergyBurned)) calories today!")
                    }
                    else {
                        updateCircleProgress(currentValue: currentValue, targetValue: targetValue)          //OUTCOME 4-> TARGET REACHED and must stop
                        setUpLabels(current: currentValue, target: targetValue,
                                    needText: "You did it! Careful though, \(Int(currentValue) - Int(targetValue)) extra calories.",
                                    burnedText: "You've burned \(Int(activeEnergyBurned)) calories today! Go burn some more to get in the range!")
                    }
                }
            }
        }
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
    @objc func fetchActiveEnergyBurned(from healthStore: HKHealthStore, energyType: HKObjectType) {
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
    
    func circleProperties() {
        circleView.layer.borderWidth = 0.0 // Set border width to 0
        circleView.layer.borderColor = UIColor.clear.cgColor // Set border color to clear color
        circleView.layer.cornerRadius = circleView.frame.size.width / 2.0
        circleView.clipsToBounds = true
    }
    
    func setUpLabels(current currentValue: Double, target targetValue: Double, needText text1: String, burnedText text2: String) {
        let neededCalorieLabel = UILabel(frame: CGRect(x: 0, y: circleView.frame.size.height/2 - 30, width: circleView.frame.size.width, height: 20))
        neededCalorieLabel.textAlignment = .center
        neededCalorieLabel.font = UIFont.systemFont(ofSize: 18.0)
        neededCalorieLabel.textColor = UIColor.black
        neededCalorieLabel.numberOfLines = 2
        neededCalorieLabel.adjustsFontSizeToFitWidth = true
        circleView.addSubview(neededCalorieLabel)
        
        let burnedCalorieLabel = UILabel(frame: CGRect(x: 0, y: circleView.frame.size.height/2, width: circleView.frame.size.width, height: 20))
        burnedCalorieLabel.textAlignment = .center
        burnedCalorieLabel.font = UIFont.systemFont(ofSize: 18.0)
        burnedCalorieLabel.textColor = UIColor.red
        burnedCalorieLabel.numberOfLines = 2
        burnedCalorieLabel.adjustsFontSizeToFitWidth = true
        neededCalorieLabel.text = text1
        burnedCalorieLabel.text = text2
        
        circleView.addSubview(burnedCalorieLabel)
    }
    
    private func animateCircleAppearance() {
        circleView.transform = CGAffineTransform(scaleX: 0.0, y: 0.0) // Set initial scale to 0
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            UIView.animate(withDuration: 0.5) {
                self.circleView.transform = .identity // Animate to the original scale
            }
        }
    }
    
    private func animateLabelChange(label: UILabel, newText: String, duration: TimeInterval) {
        UIView.transition(with: label, duration: duration, options: .transitionCrossDissolve, animations: {
            label.text = newText
        }, completion: nil)
    }
}

