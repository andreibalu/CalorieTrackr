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
//    private let testingTimeInterval: TimeInterval = 10 // 600 seconds = 10 minutes
    
    
    @IBOutlet weak var circleView: UIView!
    @IBOutlet weak var muscleImage: UIImageView!
    @IBOutlet weak var streakLabel: UILabel!
    @IBOutlet weak var targetLabel: UILabel!
    @IBOutlet weak var messageLabel: UILabel!
    
    private var activeEnergyBurned: Double = 0.0
    private var target : Int = 0
    private var streak = UserDefaults.standard.integer(forKey: K.userDefaults.userStreak)
    private var weight : Int = 0
    private var ideal : Int = 0
    private var streakChecker = UserDefaults.standard.bool(forKey: K.userDefaults.streakCheck)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        foodService = FoodService()
        
        healthAuthAndGetEnergy()
        circleProperties()
        animateCircleAppearance()
        NotificationCenter.default.addObserver(self, selector: #selector(self.handleActiveEnergyBurnedValue(_:)), name: NSNotification.Name(rawValue: K.Api.food.notif), object: nil)
        self.animateLabelChange(label: self.streakLabel, newText: "Streak: \(streak) days", duration: 1)
        messageLogic()
        muscleImage.image = UIImage(imageLiteralResourceName: K.Images.muscle)
        
        if let currentUser = Auth.auth().currentUser?.email{
            print(currentUser as Any)
            let userDocumentRef = db.collection(K.FStore.collectionName).document(currentUser)
            DispatchQueue.main.asyncAfter(deadline: .now()) {  // maybe add a few secs if errors
                userDocumentRef.getDocument { (document, error) in
                    if let document = document, document.exists {
                        //                        if let streakValue = document.data()?[K.FStore.streak] as? String {
                        //                            self.streak = Int(streakValue)!
                        //                            print("streakValue in auth: \(streakValue) days")
                        //                            self.animateLabelChange(label: self.streakLabel, newText: "Streak: \(streakValue) days", duration: 1)
                        //                        } else { print("Couldnt get streak")}
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
            print("Fetched Active Energy Burned: \(Int(value)).")
            
            let currentValue = self.foodService.getTotalCaloriesFromMealFile() - activeEnergyBurned
            let targetValue = Double(target)
            print("Current food-burned=\(Int(self.foodService.getTotalCaloriesFromMealFile())) - \(Int(activeEnergyBurned)) and target in circle=\(targetValue)")
            if self.foodService.getTotalCaloriesFromMealFile() == 0.0 {                                         //OUTCOME 1->Cals burned> cals ate
                updateCircleProgress(currentValue: 0.0, targetValue: targetValue)
                setUpLabels(current: currentValue, target: targetValue,
                            needText: "Eat something!",
                            burnedText: "You've burned \(Int(activeEnergyBurned)) calories today, but ate none !")
            }
            else {
                if ( weight < ideal) { //gain weight
                    if (targetValue > currentValue) { //progressing target
                        updateCircleProgress(currentValue: currentValue, targetValue: targetValue)
                        setUpLabels(current: currentValue, target: targetValue,                    //OUTCOME 2 gaining weight and under target
                                    needText: "You still need \(Int(targetValue) - Int(currentValue)) calories.",
                                    burnedText: "You've burned \(Int(activeEnergyBurned)) calories today!")
                    }
                    else { // over target while gaining weight
                        updateCircleProgress(currentValue: currentValue, targetValue: targetValue)          //OUTCOME 3-> gaining weight and over target
                        setUpLabels(current: currentValue, target: targetValue,
                                    needText: "You did it! You have \(Int(currentValue) - Int(targetValue)) extra calories.",
                                    burnedText: "You've burned \(Int(activeEnergyBurned)) calories today!")
                        print("Will update streak next day if user keeps up!")
                        streakChecker = true
                    }
                }
                else { // losing weight
                    if (targetValue > currentValue) { //progressing target
                        updateCircleProgress(currentValue: currentValue, targetValue: targetValue)
                        setUpLabels(current: currentValue, target: targetValue,                    //OUTCOME 2-> losing weight and under target
                                    needText: "You still need \(Int(targetValue) - Int(currentValue)) calories.",
                                    burnedText: "You've burned \(Int(activeEnergyBurned)) calories today!")
                    }
                    else { //over target while losing weight
                        if( currentValue - targetValue > 200.0){
                            updateCircleProgress(currentValue: currentValue, targetValue: targetValue)      //OUTCOME 4-> losing weight and big over target
                            setUpLabels(current: currentValue, target: targetValue,
                                        needText: "You were a bit too hungry! \(Int(currentValue) - Int(targetValue)) extra calories.",
                                        burnedText: "You've burned \(Int(activeEnergyBurned)) calories today! Go burn some more to get in the range!")
                        }
                        else {
                            updateCircleProgress(currentValue: currentValue, targetValue: targetValue)     //OUTCOME 5-> losing weight and in target
                            setUpLabels(current: currentValue, target: targetValue,
                                        needText: "You did it! Now stay in range!",
                                        burnedText: "You've burned \(Int(activeEnergyBurned)) calories today!")
                            print("Will update streak next day if user keeps up!")
                            streakChecker = true
                        }
                    }
                }
            }
            if streakChecker {
                UserDefaults.standard.set(true, forKey: K.userDefaults.streakCheck)
            } else {
                UserDefaults.standard.set(false, forKey: K.userDefaults.streakCheck)
            }
            print("streak checker after it sets is \(UserDefaults.standard.bool(forKey: K.userDefaults.streakCheck))")
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
    
    private func messageLogic() {
        switch streak {
        case 0:
            animateLabelChange(label: messageLabel, newText: "The first day is the hardest !", duration: 2.0)
        case 1...3:
            animateLabelChange(label: messageLabel, newText: "Keep going ! You're just getting started !", duration: 2.0)
        case 4...10:
            animateLabelChange(label: messageLabel, newText: "You're getting the hang of it !", duration: 2.0)
        case 11...:
            animateLabelChange(label: messageLabel, newText: "Sky is the limit 💪🏻", duration: 2.0)
        default:
            print("Couldn't get streak value")
        }
    }
    
//testing updateStreak()
//    {
//        print("Did he reach target? \(streakChecker)")
//        if let storedDate = UserDefaults.standard.object(forKey: "lastAccessedDate") as? Date {
//            print("Last accessed this app on: \(storedDate). Will check if it was within the testing interval.Current time:\(Date.now)")
//
//            let isLastAccessOlderThanInterval = Date().timeIntervalSince(storedDate) >= testingTimeInterval
//
//            if isLastAccessOlderThanInterval {
//                print("Will update streak if user reached target during last interval")
//                print(UserDefaults.standard.bool(forKey: K.userDefaults.streakCheck))
//                if UserDefaults.standard.bool(forKey: K.userDefaults.streakCheck) {
//                    streak = streak + 1
//                    UserDefaults.standard.set(streak, forKey: K.userDefaults.userStreak)
//                    print("Updated streak in userdefaults to new value: \(streak)")
//                }
//                streakChecker = false
//                UserDefaults.standard.set(streakChecker, forKey: K.userDefaults.streakCheck)
//            } else {
//                print("App was accessed within the testing interval. Current streak is \(streak)")
//            }
//        } else {
//            print("Can't get last accessed date for app.")
//        }
//        UserDefaults.standard.set(Date(), forKey: "lastAccessedDate")
//    }
//testing updateStreak()
    
    
    func updateStreak() {
        print("Did he reach the target? \(UserDefaults.standard.bool(forKey: K.userDefaults.streakCheck))")
        if let storedDate = UserDefaults.standard.object(forKey: "lastAccessedDate") as? Date {
            print("Last accessed this app on: \(storedDate). Will check if it was yesterday. Current time:\(Date.now)")
            if Calendar.current.isDateInYesterday(storedDate) {
                print("Will update streak if streak check is true => \(UserDefaults.standard.bool(forKey: K.userDefaults.streakCheck))")
                if UserDefaults.standard.bool(forKey: K.userDefaults.streakCheck) { // if user reached target yesterday
                    streak = streak + 1
                    UserDefaults.standard.set(streak, forKey: K.userDefaults.userStreak)
                    print("Updated streak in userdefaults to new value: \(streak)")
                } else { //if he last accessed the app yesterday, and streak checker is off, will reset streak
                    streak = 0
                    UserDefaults.standard.set(streak, forKey: K.userDefaults.userStreak)
                    print("Reseting streak, user did not achieve target, even though last accessed was yesterday")
                }
                streakChecker = false   //make sure streak checker is on false, either if he did it yesterday or not
                UserDefaults.standard.set(streakChecker, forKey: K.userDefaults.streakCheck)
            } else if Calendar.current.isDateInToday(storedDate) {
                print("It is was accessed today already, wont update streak in firebase. \(Date.now). Current streak is \(streak)")
            } else { //it was accessed last time more than 2 days ago, so delete streak
                print("it was accessed some older time, will reset streak value in userDefaults")
                streak = 0
                UserDefaults.standard.set(streak, forKey: K.userDefaults.userStreak)
            }
        } else {
            print("Can't get last accessed date for app.")
        }
        // Update the last accessed date to now
        UserDefaults.standard.set(Date(), forKey: "lastAccessedDate")
    }
}

