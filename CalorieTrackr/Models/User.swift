//
//  User.swift
//  CalorieTrackr
//
//  Created by Andrei Baluta on 26.04.2023.
//

import Foundation

struct User {
    var name: String
    var sex : String
    var age: Int
    var height: Int
    var weight: Double
    var weightGoal: Double
    var weeksGoal: Double
    var activity: Int
    var streak: Int
    
    init(name: String, sex: String, age: Int, height: Int, weight: Double, weightGoal: Double, weeksGoal: Double, activity: Int, streak: Int) {
        self.name = name
        self.sex = sex
        self.age = age
        self.height = height
        self.weight = weight
        self.weightGoal = weightGoal
        self.weeksGoal = weeksGoal
        self.activity = activity
        self.streak = streak
    }
    
    mutating func setName(name : String) {
        self.name = name
    }
}
